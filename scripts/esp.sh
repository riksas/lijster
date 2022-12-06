#!/bin/bash
#

NAME=espserver
#LICENSECONTENT=`base64 -w 0 /home/sas/dockercontent/esp/SASViyaV0300_9C78Q3_Linux_x86-64.txt`
LICENSECONTENT=`base64 -w 0 /home/ubuntu/docker/license.txt`
#IPADDRESS=`ifconfig enp0s3 |grep 'inet ' |awk '{print $2}'`

#COMMANDSTART="docker run --name $NAME -v /home/sas/dockercontent/esp:/data --privileged --group-add dialout --device=/dev/virtual-tty:/dev/ttyS0 --add-host postgres:$IPADDRESS --add-host mqtt:$IPADDRESS -d --restart unless-stopped -p 31415:31415 -p 31416:31416  --env ODBCINI=/data/odbc.ini --env#### SETINIT_TEXT_ENC=$LICENSECONTENT --env DFESP_CONFIG=/data esp6.1:1.0"

COMMANDSTART="docker run --name $NAME -v /home/ubuntu/docker/data:/data -d --restart unless-stopped -p 31415:31415 -p 31416:31416  --env SETINIT_TEXT_ENC=$LICENSECONTENT --env DFESP_CONFIG=/data sasesp.6.1"

NUMPODS=`docker ps | grep $NAME | wc -l`

status() {
    echo
    echo "==== Status"

    if [[ $NUMPODS -eq 0 ]]
    then
        echo
        echo "$NAME is not running"
        echo
    elif [[ $NUMPODS -eq 1 ]]
	then
        echo
        echo "$NAME is running"
        echo
	else
        echo
        echo "$NUMPODS instances of $NAME are running"
        echo
    fi
}

start() {
    echo
    echo "==== Start"

    if [[ $NUMPODS -eq 0 ]]
    then
        echo
        echo "Starting pod $NAME"
        echo
		$COMMANDSTART
    elif [[ $NUMPODS -eq 1 ]]
	then
        echo
        echo "Pod $NAME is already started"
        echo
	else
        echo
        echo "$NUMPODS instances of $NAME are running"
        echo
    fi
}


stop() {
    echo
    echo "==== Stop"

    if [[ $NUMPODS -eq 0 ]]
    then
        echo
        echo "Pod $NAME is already stopped"
        echo
    elif [[ $NUMPODS -eq 1 ]]
	then
        echo
        echo "Stopping pod $NAME"
        echo
        docker stop $NAME
		docker rm $NAME
	else
        echo
        echo "$NUMPODS instances of $NAME are running"
        echo
    fi
}


log() {
    echo
    echo "==== Log" 

    if [[ $NUMPODS -eq 0 ]]
    then
        echo
        echo "Pod $NAME is already stopped"
        echo
    elif [[ $NUMPODS -eq 1 ]]
	then
        echo
        echo "Showing log of pod $NAME"
        echo
		docker logs $NAME
	else
        echo
        echo "$NUMPODS instances of $NAME are running"
        echo
    fi
}

logfile() {
    echo
    echo "==== Log" 

    if [[ $NUMPODS -eq 0 ]]
    then
        echo
        echo "Pod $NAME is already stopped"
        echo
    elif [[ $NUMPODS -eq 1 ]]
	then
        echo
        echo "Showing log of pod $NAME"
        echo
		docker inspect $NAME |grep LogPath
	else
        echo
        echo "$NUMPODS instances of $NAME are running"
        echo
    fi
}


shell() {
    echo
    echo "==== Shell" 

    if [[ $NUMPODS -eq 0 ]]
    then
        echo
        echo "Pod $NAME is already stopped"
        echo
    elif [[ $NUMPODS -eq 1 ]]
	then
        echo
        echo "Running shell in pod $NAME"
        echo
		docker exec -it $NAME /bin/bash
	else
        echo
        echo "$NUMPODS instances of $NAME are running"
        echo
    fi
}

shellAsRoot() {
    echo
    echo "==== Shell as root" 

    if [[ $NUMPODS -eq 0 ]]
    then
        echo
        echo "Pod $NAME is already stopped"
        echo
    elif [[ $NUMPODS -eq 1 ]]
	then
        echo
        echo "Running shell in pod $NAME"
        echo
		docker exec -itu root $NAME /bin/bash
	else
        echo
        echo "$NUMPODS instances of $NAME are running"
        echo
    fi
}



case "$1" in
    'start')
            start
            ;;
    'stop')
            stop
            ;;
    'restart')
            stop 
			echo "Sleeping..."
			sleep 1 
			NUMPODS=`docker ps | grep $NAME | wc -l`
            start
            ;;
    'status')
            status
            ;;
    'log')
            log
            ;;
    'logfile')
            logfile
            ;;
    'shell')
            shell
            ;;
    'shellAsRoot')
            shellAsRoot
            ;;
    *)
            echo
            echo "Usage: $0 { start | stop | restart | status | log | logfile | shell | shellAsRoot}"
            echo
            exit 1
            ;;
esac

exit 0