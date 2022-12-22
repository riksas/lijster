
![SAS VA Report](/sas VA/Screenshot.PNG "SAS VA Report")

<img src="/sas VA/Screenshot.PNG" alt="SAS VA Report" style="height: 100px; width:100px;"/>


# 1. Lijster Project - Read Gas and Electricity Usage using SAS ESP on an edge device

- [1. Lijster Project - Read Gas and Electricity Usage using SAS ESP on an edge device](#1-lijster-project---read-gas-and-electricity-usage-using-sas-esp-on-an-edge-device)
  - [1.1. Install Ubuntu on BasPi](#11-install-ubuntu-on-baspi)
    - [1.1.1. Use correct images: arm or x64 linux? https://en.wikipedia.org/wiki/AArch64](#111-use-correct-images-arm-or-x64-linux-httpsenwikipediaorgwikiaarch64)
    - [1.1.2. version of linux?](#112-version-of-linux)
    - [1.1.3. Steps](#113-steps)
    - [1.1.4. Add user sas with pw sas](#114-add-user-sas-with-pw-sas)
    - [1.1.5. change hostname](#115-change-hostname)
  - [1.2. Install ESP on the Edge](#12-install-esp-on-the-edge)
    - [1.2.1. Get software](#121-get-software)
    - [1.2.2. install locally](#122-install-locally)
    - [1.2.3. ESP Server CLI start server on the edge](#123-esp-server-cli-start-server-on-the-edge)
  - [1.3. Install on docker](#13-install-on-docker)
    - [1.3.1. install.sh](#131-installsh)
    - [1.3.2. Extra:](#132-extra)
    - [1.3.3. troubleshooting:](#133-troubleshooting)
  - [1.4. test on BASPi docker](#14-test-on-baspi-docker)
  - [1.5. Monitor the project](#15-monitor-the-project)
  - [1.6. Reading thermometer data on BasPi:](#16-reading-thermometer-data-on-baspi)
  - [1.7. Add slimme meter http://www.gejanssen.com/howto/Slimme-meter-uitlezen/](#17-add-slimme-meter-httpwwwgejanssencomhowtoslimme-meter-uitlezen)
    - [1.7.1. Slimme meter](#171-slimme-meter)
    - [1.7.2. P1 Telegram](#172-p1-telegram)
- [2. Data processing and reporting](#2-data-processing-and-reporting)
  - [2.1. ESP Connect](#21-esp-connect)
    - [2.1.1. Use ESP connect](#211-use-esp-connect)
- [3. FTP](#3-ftp)
    - [3.0.1. use ftp server https://ubuntu.com/server/docs/service-ftp  in first version](#301-use-ftp-server-httpsubuntucomserverdocsservice-ftp--in-first-version)
- [4. Issues](#4-issues)
    - [4.0.1. Issue with ttyS0 --\> need to run after restart of BASPi](#401-issue-with-ttys0----need-to-run-after-restart-of-baspi)
    - [4.0.2.  regex Temp](#402--regex-temp)
    - [4.0.3. fix issue with with TLS mixed content:](#403-fix-issue-with-with-tls-mixed-content)
    - [4.0.4. change time on Pi](#404-change-time-on-pi)
    - [4.0.5. issue with sudoers file:](#405-issue-with-sudoers-file)
    - [4.0.6. summer time correction (fixed)](#406-summer-time-correction-fixed)
    - [4.0.7. stop project from web interface (skip)](#407-stop-project-from-web-interface-skip)
    - [4.0.8. opening model from web interface (skip)](#408-opening-model-from-web-interface-skip)
    - [4.0.9. max power  (added)](#409-max-power--added)
    - [4.0.10. usage instead of meter readings  (done)](#4010-usage-instead-of-meter-readings--done)
    - [4.0.11. Add thermostaat program  (done in VA Autoload)](#4011-add-thermostaat-program--done-in-va-autoload)
    - [4.0.12. symbolic link from sas web server to ESP connect](#4012-symbolic-link-from-sas-web-server-to-esp-connect)
      - [4.0.12.1. Symbolic link](#40121-symbolic-link)
      - [4.0.12.2. Edit config C:\\SAS\\Config\\Lev1\\Web\\WebServer\\conf\\sas.conf](#40122-edit-config-csasconfiglev1webwebserverconfsasconf)
      - [4.0.12.3. Use new links in VA: http://snlsea.emea.sas.com/esp-connect/examples/lijster/currentpower.html](#40123-use-new-links-in-va-httpsnlseaemeasascomesp-connectexampleslijstercurrentpowerhtml)
    - [4.0.13. Open from outside the network](#4013-open-from-outside-the-network)
    - [4.0.14. Archiving of data](#4014-archiving-of-data)
    - [4.0.15. secure ftp](#4015-secure-ftp)
- [5. At startup of raspberry PI (this is now automated)](#5-at-startup-of-raspberry-pi-this-is-now-automated)
    - [5.0.1. list settings](#501-list-settings)
  
## 1.1. Install Ubuntu on BasPi 
### 1.1.1. Use correct images: arm or x64 linux? https://en.wikipedia.org/wiki/AArch64
```
uname -m
```
### 1.1.2. version of linux?  
```
cat /etc/os-release  
hostnamectl  
```
### 1.1.3. Steps
1. Format micro SD to fat32 with Powershell: format /FS:FAT32 D:
2. Get ubuntu server image: for ARM https://ubuntu.com/download/raspberry-pi
3. Put it on micro sd Use Win32 Disk imager 
4. Install ssh https://likegeeks.com/ssh-connection-refused/
5. Install docker https://pimylifeup.com/ubuntu-install-docker/
6. Retrieve required files from SAS https://go.documentation.sas.com/doc/en/espcdc/v_005/dplyedge0phy0lax/p1goagdh3x1uqdn1m1rn57lngpud.htm

### 1.1.4. Add user sas with pw sas
```
sudo userdel sas 
sudo sudo adduser sas  
sudo groupadd sas  
sudo usermod -a -G docker sas dialout  
id sas  
newgrp docker 
``` 
- add user sas to dialout group  
```
usermod -aG sudoers
```

### 1.1.5. change hostname
I use baspi.localdomain
https://www.cyberciti.biz/faq/ubuntu-18-04-lts-change-hostname-permanently/

## 1.2. Install ESP on the Edge
### 1.2.1. Get software
- Video from SAS: Daniel Kuiper 
https://communities.sas.com/t5/SAS-Communities-Library/Real-time-computer-vision-on-an-edge-device-2-ESP-edge/ta-p/788416
- You need a second Linux server to do this, I use an Ubuntu image on my laptop.
1. download certificates, licence, and mirror manager for linux (in C:\Users\SNLSEA\OneDrive - SAS\course\ESP 6.1 Workshop Alfredo\lijster)
2. copy them to the workshop image esp.localdomain
3. untar the mirrormgr-linux.tgz 
   tar -xvzf mirrormgr-linux.tgz  
4. move edge_mirror   
   mv esp-edge-extension/viya4/edge_mirror.sh .
5. chmod +x mirrormgr
   chmod +x edge_mirror.sh
6. download using 
7. move files from workshop image to pi
    

```
ssh sas@172.28.225.213
mkdir deploy
exit
cd /home/sas/edge/
scp -r espedge_repos/ sas@172.28.225.213:~/deploy
scp -r SASViyaV4_0B17MY_lts_2021.2_license_2022-01-20T103652.jwt sas@172.28.225.213:~/deploy
ssh bas@172.28.225.213
sudo mv /deploy/SASViyaV4_0B17MY_lts_2021.2_license_2022-01-20T103652.jwt /opt/sas/viya/home/SASEventStreamProcessingEngine/etc/license/
```
### 1.2.2. install locally
On pi:
```
sudo apt install /home/sas/deploy/espedge_repos/aarch64-ubuntu-linux-16/basic/*
sudo apt install /home/sas/deploy/espedge_repos/aarch64-ubuntu-linux-16/analytics/*
sudo apt install /home/sas/deploy/espedge_repos/aarch64-ubuntu-linux-16/astore/* 
sudo apt install /home/sas/deploy/espedge_repos/aarch64-ubuntu-linux-16/textanalytics/* 
sudo apt install /home/sas/deploy/espedge_repos/aarch64-ubuntu-linux-16/gpu/* 
```
- move license file 
```
ssh sas@172.28.225.213
sudo mv /home/sasdeploy/SASViyaV4_0B17MY_lts_2021.2_license_2022-01-20T103652.jwt /opt/sas/viya/home/SASEventStreamProcessingEngine/etc/license/
```

### 1.2.3. ESP Server CLI start server on the edge
```
export DFESP_HOME=/opt/sas/viya/home/SASEventStreamProcessingEngine/  
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DFESP_HOME/ssl/lib:$DFESP_HOME/lib:/opt/sas/viya/home/SASFoundation/sasexe:/usr/lib  
export PATH=$PATH:$DFESP_HOME/bin  
dfesp_xml_server -http 31415 -pubsub 31416 
dfesp_xml_server -http 31415 -pubsub 31416 -loglevel "esp=error,common.http=debug,esp.windows=trace"  
```
- or
```  
nohup dfesp_xml_server -http 31415 -pubsub 31416 >/tmp/esp-server.log &
tail -f /tmp/esp-server.log
```
- stop server   
```
dfesp_xml_client -url "http://baspi:31415/eventStreamProcessing/v1/server/state?value=stopped" -put
```

## 1.3. Install on docker

- See also:
- ESP with Docker Workshop (internal video)
https://web.microsoftstream.com/video/fc10393e-1753-4e09-8770-be98ca8c219e at 1:37:30
and
https://docs.docker.com/get-started/overview/
```
 apt install net-tools  
```
 
1. Create local registry  
```
docker run -d -p 5000:5000 --restart=always --name registry registry:2  
```

2. Create docker folder en copy the files
```
cd ~   
mkdir docker  
cd docker  
cp -r ~/deploy/espedge_repos/aarch64-ubuntu-linux-16/ .  
cp -r "/opt/sas/viya/home/SASEventStreamProcessingEngine/etc/license/SASViyaV4_0B17MY_lts_2021.2_license_2022-01-20T103652.jwt" .  
```
3. package using  tar  
```
tar -cvzf dockeresp2021_1.tar *  
copy Dockerfile en install.sh  en Dockerfile naar ~/docker/  
```
https://www.cyberciti.biz/faq/explain-debian_frontend-apt-get-variable-for-ubuntu-debian/


4. install ubuntu 20.04 on the docker see 21:10 2e video  
```
sudo -i
sudo snap install docker 
cd ~/docker/
sudo docker pull ubuntu
sudo docker pull ubuntu:20.04
```
5. To this ubuntu we refer to in the first lines of the Dockerfile: FROM ubuntu:20.04  
  - For root password for ubuntu:
   https://linuxconfig.org/default-root-password-on-ubuntu-18-04-bionic-beaver-linux

6. docker build  


### 1.3.1. install.sh  
```
#!/bin/bash
#

#cd /tmp
#mkdir /tmp/install
cd /tmp/install
#tar -xvzf /tmp/dockeresp2021_1.tar

DEBIAN_FRONTEND=noninteractive apt-get -yq update
DEBIAN_FRONTEND=noninteractive apt-get -yq install apt-utils
DEBIAN_FRONTEND=noninteractive apt-get -yq install curl


DEBIAN_FRONTEND=noninteractive apt-get -yq install /tmp/install/aarch64-ubuntu-linux-16/basic/*
DEBIAN_FRONTEND=noninteractive apt-get -yq install /tmp/install/aarch64-ubuntu-linux-16/analytics/*
DEBIAN_FRONTEND=noninteractive apt-get -yq install /tmp/install/aarch64-ubuntu-linux-16/textanalytics/*
DEBIAN_FRONTEND=noninteractive apt-get -yq install /tmp/install/aarch64-ubuntu-linux-16/astore/*
DEBIAN_FRONTEND=noninteractive apt-get -yq install /tmp/install/aarch64-ubuntu-linux-16/gpu/*


cp /tmp/install/SASViyaV4_0B17MY_lts_2021.2_license_2022-01-20T103652.jwt /opt/sas/viya/home/SASEventStreamProcessingEngine/etc/license/SASViyaV4_0B17MY_lts_2021.2_license_2022-01-20T103652.jwt
chown sas:sas /opt/sas/viya/home/SASEventStreamProcessingEngine/etc/license/SASViyaV4_0B17MY_lts_2021.2_license_2022-01-20T103652.jwt


chown sas:sas /opt/sas/viya/home/SASEventStreamProcessingEngine/lib/* 

cd /
rm -r /tmp/install
```
- Dockerfile  
``` 
FROM ubuntu:20.04

ENV DFESP_CONFIG=/data
ENV ODBCINI=/data/odbc.ini
ENV MAS_M2PATH=/opt/sas/viya/home/SASFoundation/misc/embscoreeng/mas2py.py
ENV MAS_PYPATH=/usr/bin/python3.8
ENV BASE_PRIMARY_LICENSE="SAS"
ENV BASE_PRIMARY_LICENSE_LOC=/data/SASViyaV4_0B17MY_lts_2021.2_license_2022-01-20T103652.jwt
ENV DFESP_HOME=/opt/sas/viya/home/SASEventStreamProcessingEngine
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$DFESP_HOME/ssl/lib:$DFESP_HOME/lib:/opt/sas/viya/home/SASFoundation/sasexe:/usr/lib"
ENV PATH=$PATH:$DFESP_HOME/bin
ENV SAS_VIYA_ENABLED=false

WORKDIR /tmp/install
ADD dockeresp2021_1.tar .
ADD install.sh .
RUN chmod u+x ./install.sh & /bin/bash ./install.sh
#ENTRYPOINT ["/bin/bash", "/install.sh"]
USER sas
CMD ["/opt/sas/viya/home/SASEventStreamProcessingEngine/bin/dfesp_xml_server"] 
```

4.2 build  
```
cd ~/docker/
docker build -t sasesp.2021.1:20220413.133100 .
```
4.3 add tags
```
docker images
docker image tag <id> sasesp.2021.1
docker image tag 6c3a02225d27  sasesp.2021.1
```
or:  
Since 1.10 release, you can now add multiple tags at once on build:
```
docker build -t name1:tag1 -t name1:tag2 -t name2 .
```

5. If something goes wrong you can clean up using: ( c2038f1eefae = image id):
```
docker image ls
docker image prune
docker stop f98c0c534e46
docker rm -f f98c0c534e46
docker stop caf0ca41cbea
docker rm caf0ca41cbea
docker image rm c2038f1eefae
docker image ls -a
docker ps -a
docker rm espserver.
```


6. copy esp-properties and jndi.properties from local install to docker  
```
cd ~/docker/
mkdir data
cp /opt/sas/viya/config/etc/SASEventStreamProcessingEngine/default/* data
```
6.2.  Edit esp-properties:  
```
connectors:
  excluded:
    mq: true
    tibrv: true
    sol: true
    tva: true
    pi: true
    tdata: true
    rmq: false
    sniffer: true
    mqtt: false
    pylon: true
    modbus: false
```
6. run docker  
```
docker run --name espserver -v ~/docker/data:/data .
docker run --name $NAME -v /home/ubuntu/docker/data:/data -d --restart unless-stopped -p 31415:31415 -p 31416:31416 --tty --group-add dialout --device=/dev/ttyS0:/dev/ttyS0 --env SETINIT_TEXT_ENC=$LICENSECONTENT --env DFESP_CONFIG=/data sasesp.2021.1
docker exec  -itu root espserver /bin/bash
curl http://baspi:31415/SASESP
```


### 1.3.2. Extra:
To start docker with ubuntu user:

https://www.digitalocean.com/community/questions/how-to-fix-docker-got-permission-denied-while-trying-to-connect-to-the-docker-daemon-socket

**the groupadd command creates a new group.
```
sudo groupadd docker
```
The command ‘usermod‘ is used to modify or change any attributes of a already created user account via command line.
   -a = To add anyone of the group to a secondary group.  
   -G = To add a supplementary groups.  
 $USER is current user  
``` 
sudo usermod -aG docker $USER
```
To start docker  using the esp.sh script of Alfredo:  /home/ubuntu/scripts  


### 1.3.3. troubleshooting:
1. docker error - 'name is already in use by container'  
step 1:(it lists docker container with its name)
docker ps -a
step 2:
docker rm name_of_the_docker_container
stop is ctrl-c

 
## 1.4. test on BASPi docker
```
cd ~/docker
./esp.sh start
docker exec  -itu root espserver /bin/bash 
./esp.sh shellAsRoot

cd /data
```
-  check if projects are running  
```
dfesp_xml_client -url "http://baspi:31415/eventStreamProcessing/v1/projects"
```
-  load project and run
```
dfesp_xml_client -url "http://baspi:31415/eventStreamProcessing/v1/projectResults?windows=ParseMessage" -post  "file://lijster.xml"  
dfesp_xml_client -url "http://baspi:31415/eventStreamProcessing/v1/projectResults" -post  "file://lijster.xml"  
dfesp_xml_client -url "http://baspi:31415/SASESP/projects/connectlijster" -put "file://connectlijster.xml"
dfesp_xml_client -url "http://baspi:31415/SASESP/projects/lijster" -put  "file://lijster.xml"
```

-  start loaded project
```
dfesp_xml_client -url "http://baspi:31415/SASESP/projects/connectlijster/state?value=running" -put
dfesp_xml_client -url "http://baspi:31415/SASESP/projects/lijster/state?value=running" -put
```
- check count
```
dfesp_xml_client -url "http://baspi:31415/eventStreamProcessing/v1/windows?count=true"
```
- view events:
```
dfesp_xml_client -url "http://baspi:31415/eventStreamProcessing/v1/events?windowFilter=eq(type,'window-aggregate')"
```
-  stop a project
```
dfesp_xml_client -url "http://baspi:31415/eventStreamProcessing/v1/projects/lijster/state?value=stopped" -put
dfesp_xml_client -url "http://baspi:31415/eventStreamProcessing/v1/projects/connectlijster/state?value=stopped" -put
dfesp_xml_client -url "http://baspi:31415/eventStreamProcessing/v1/projects/connectlijster/state?value=started" -put
```
- delete project
```
dfesp_xml_client -url "http://baspi:31415/eventStreamProcessing/v1/projects/lijster" -delete
dfesp_xml_client -url "http://baspi:31415/eventStreamProcessing/v1/projects/connectlijster" -delete
dfesp_xml_client -url "http://baspi:31415/eventStreamProcessing/v1/projects/trades" -delete
```
- stop server
```
dfesp_xml_client -url "http://baspi:31415/eventStreamProcessing/v1/server/state?value=stopped" -put  
```
- restart baspi
To stop all projects, run the following command:
```
dfesp_xml_client -url "http://host :port/eventStreamProcessing/v1/stoppedProjects/project" -post
  sudo shutdown -r now
```

## 1.5. Monitor the project  

View counts
http://baspi.localdomain:31415/eventStreamProcessing/v1/windows?count=true

View Stats
http://baspi.localdomain:31415/eventStreamProcessing/v1/projectStats?memory=true

View projects
http://baspi.localdomain:31415/eventStreamProcessing/v1/projects



--- 

## 1.6. Reading thermometer data on BasPi:
https://cdn.en.papouch.com/data/user-content/old_eshop/files/TM/tm_en.pdf
This will set the baud rate to 9600, 8 bits, 1 stop bit, no parity:
sudo stty -F /dev/ttyS0 9600 cs8 -cstopb -parenb  
cat /dev/ttyS0

Test file does not contain a key column, so use autogen, set key as last column in output schema, and  use following properties:
```
        <property name="csvfielddelimiter"><![CDATA[,]]></property>  
        <property name="noautogenfield"><![CDATA[false]]></property>  
        <property name="addcsvopcode"><![CDATA[true]]></property>  
        <property name="addcsvflags"><![CDATA[normal]]></property>  
        <property name="fsname"><![CDATA[/mnt/data/input/lijster/testdata.csv]]></property>  
```

A CSV publisher converts each line into an event. The first two values of each
line are expected to be an opcode flag and an event flag. Use the addcsvopcode
and addcsvflags parameters when any line in the CSV file does not include an
opcode and event flag.

---

## 1.7. Add slimme meter http://www.gejanssen.com/howto/Slimme-meter-uitlezen/  
### 1.7.1. Slimme meter
```
sudo apt update
sudo apt install cu
cu -l /dev/ttyUSB0 -s 115200 --parity=none -E q &
```

To close cu, type “q.”, press Enter and wait a few seconds. The programm closes with the message Disconnected..

```
stty -F /dev/ttyUSB0 raw 115200 evenp
cat /dev/ttyUSB0
```

### 1.7.2. P1 Telegram

```
/ISK5\2M550T-1012			              											Header information

1-3:0.2.8(50)																					Version informationfor P1 output DSMR version 5.0
0-0:1.0.0(220711112847S)											Date-time stamp of the P1 message
0-0:96.1.1(4530303434303037343534313636333139)  						Equipment identifier
1-0:1.8.1(002872.376*kWh)                                           Meter Reading electricity delivered to client (Tariff 1 low) in 0,001 kWh
1-0:1.8.2(003551.917*kWh)                                           Meter Reading electricity delivered to client (Tariff 2 high) in 0,001 kWh     
1-0:2.8.1(000000.000*kWh)											Meter Reading electricity delivered by client (Tariff 1 low) in 0,001 kWh
1-0:2.8.2(000000.006*kWh)                                           Meter Reading electricity delivered by client (Tariff 2 high) in 0,001 kWh
0-0:96.14.0(0002)                                                   Tariff indicator electricity. The tariff indicator can also be used to switch tariff dependent loads e.g boilers. This is the responsibility of the P1 user
1-0:1.7.0(00.140*kW)                                                Actual electricity power delivered (+P) in 1 Watt resolution
1-0:2.7.0(00.000*kW)                                                Actual electricity power received (+P) in 1 Watt resolution 
0-0:96.7.21(00004)                                                  Number of power failures in any phase
0-0:96.7.9(00005)                                                   Number of long power failures in any phase
1-0:99.97.0(3)(0-0:96.7.19)(190712035024S)(0000000224*s)(200808161515S)(0000002076*s)(211208144738W)(0000003251*s) Power Failure Event Log (long power failures)
1-0:32.32.0(00000)		                                            Number of voltage sags in phase L1										
1-0:52.32.0(00000)                                                  Number of voltage sags in phase L2
1-0:72.32.0(00000)                                                  Number of voltage sags in phase L3
1-0:32.36.0(00001)													Number of voltage swells in phase L1
1-0:52.36.0(00001)													Number of voltage swells in phase L2
1-0:72.36.0(00001)													Number of voltage swells in phase L3
0-0:96.13.0()														Text message max1024 characters.
1-0:32.7.0(236.3*V)													Instantaneous voltage L1 (+P) in V resolution
1-0:52.7.0(235.0*V)                                                 Instantaneous voltage L2 (+P) in V resolution
1-0:72.7.0(237.4*V)                                                 Instantaneous voltage L3 (+P) in V resolution
1-0:31.7.0(000*A)													Instantaneous current L1 (+P) in A resolution
1-0:51.7.0(000*A)                                                   Instantaneous current L2 (+P) in A resolution
1-0:71.7.0(000*A)                                                   Instantaneous current L3 (+P) in A resolution
1-0:21.7.0(00.000*kW)												Instantaneous active power L1 (+P) in W resolution
1-0:41.7.0(00.054*kW)												Instantaneous active power L2 (+P) in W resolution
1-0:61.7.0(00.084*kW)												Instantaneous active power L3 (+P) in W resolution
1-0:22.7.0(00.000*kW)												Instantaneous active power L3 (-P) in W resolution
1-0:42.7.0(00.000*kW)                                               Instantaneous active power L2 (-P) in W resolution
1-0:62.7.0(00.000*kW)                                               Instantaneous active power L3 (-P) in W resolution
0-1:24.1.0(003)                                                  	Device-Type
0-1:96.1.0(4730303339303031393435353539363139)                   	Equipment identifier (Gas)
0-1:24.2.1(220711112500S)(03432.504*m3)                          	Last 5-minute value (temperature converted), gas delivered to client in m3, including decimal values and capture time
!7255
```

---

# 2. Data processing and reporting
1. real time power every second --> ESP connect
2. daily electricity consumption per hour (aggregated data) store  5 min data for gas, electricity and temp. --> SAS VA

---

## 2.1. ESP Connect
- add graphics using react or c3js
Recorded session by Rik de Ruiter 30-9-2021
https://sasoffice365-my.sharepoint.com/personal/alfredo_iglesias_rey_sas_com/_layouts/15/stream.aspx?id=%2Fpersonal%2Falfredo%5Figlesias%5Frey%5Fsas%5Fcom%2FDocuments%2FRecordings%2FCommunity%20van%20ESP%2D20210930%5F131022%2DMeeting%20Recording%2Emp4&ga=1


### 2.1.1. Use ESP connect

- Use powershell, http server: then nodejs  
https://github.com/sassoftware/esp-connect

PS C:\files\SourceTree\esp-connect> http-server --port 33000  
http://localhost:33000/html/modelviewer.html#
http://baspi.localdomain:31415


- OR use Visual Studio code
See 
- connect and load project in esp connect
_esp.connect(server,{ready:ready,error:error},{model:{name:_project,url:url},overwrite:true,force:_esp.getParm("force",true)});  
only connect and not load   (use project already running)
_esp.connect(server,{ready:ready,error:error},{model:null,overwrite:true,force:_esp.getParm("force",true)});  



- Swagger:
https://go.documentation.sas.com/doc/en/espcdc/6.1/espxmllayer/p111ycfjon4sran1a72zunszhq5x.htm
- [ ]
PS C:\files\SourceTree\myswagger\swagger-ui> cd ..
PS C:\files\SourceTree\myswagger> python -m http.server 55000
Serving HTTP on :: port 55000 (http://[::]:55000/) ...

---
# 3. FTP

### 3.0.1. use ftp server https://ubuntu.com/server/docs/service-ftp  in first version

https://www.cyberciti.biz/faq/howto-change-ssh-port-on-linux-or-unix-server/
Security, no write access and ssl

 Uncomment this to enable any form of FTP write command.
/etc/vsftpd.conf
#write_enable=YES

change home dir of ftp server
sudo usermod -d /home/sas/docker/data/output/lijster/ ftp 
check home dir
grep ftp /etc/passwd
restart ftp
sudo systemctl restart vsftpd.service


- Use view to autoload:
```
libname autol 'C:\SAS\Config\Lev1\AppData\SASVisualAnalytics\VisualAnalyticsAdministrator\AutoLoad';

filename p1_elec ftp 'elec_data.csv' cd='~/docker/data/output/lijster/'
   user='sas' 
   pass=sas 
   host='baspi.localdomain'
   recfm=v
   TERMSTR=LF
   PASSIVE  
   debug ;

/*filename p1_elec 'C:\temp\elec_data.csv';*/
proc delete data=autol.p1_elec (memtype=view);
run;
data autol.p1_elec 
/* Create a view */
/ view=autol.p1_elec
;   

filename p1_elec ftp 'elec_data.csv' cd='~/docker/data/output/lijster/'
   user='sas' 
   pass=sas 
   host='baspi.localdomain'
   recfm=v
   TERMSTR=LF
   PASSIVE  
   debug ;

   infile p1_elec dsd dlm=',' firstobs=2
/*obs=3     */
MISSOVER
lrecl=32767  
;
   format date datetime25.3;
   length p1_timestring $24;
   input 
   opcode $ state $  sensor_id period p1_timestring $ power electricity_low electricity_normal tariff;  
   date = Period/1;
run;

DATA view=autol.p1_elec; describe; run;
```
```
/* 
 * appserver_autoexec_usermods.sas
 *
 *    This autoexec file extends appserver_autoexec.sas.  Place your site-specific include 
 *    statements in this file.  
 *
 *    Do NOT modify the appserver_autoexec.sas file.  
 *    
 */
 
 libname autol 'C:\SAS\Config\Lev1\AppData\SASVisualAnalytics\VisualAnalyticsAdministrator\AutoLoad';

filename p1_elec ftp 'elec_data.csv' cd='~/docker/data/output/lijster/'
   user='sas' 
   pass=sas 
   host='baspi.localdomain'
   recfm=v
   TERMSTR=LF
   PASSIVE  
   debug ; 
```


- I reverse engineered the autoload process and found that this piece of code only looks at MEMTYPE=DATA. 
/opt/SAS/SASHome/SASVisualAnalyticsHighPerformanceConfiguration/7.3/Config/Deployment/Code/AutoLoad/include/GetTablesListFromLibrary.sas

I altered the use of the parameter TYPE, 2 places, to accept DATA and VIEW.
```
/*
 * GetTablesListFromLibrary()
 * 
 * Purpose: Given a libref, returns the list of members in that library.  Defaults to 
 *       tables list, unless type is specified.
 *
 * Parms:
 *       data=     The output data set to create.  If unspecified, defaults to work.tablelist.
 *      inlibref= The libref assigned to the source library to list.
 *    type=     The member type to list.  Defaults to DATA, but CATALOG can also be specified.
 */ 
%macro GetTablesListFromLibrary( data=WORK.tablelist, inlibref=, type=DATA, RENAME=NO );
   %setoption(off,notes);
   %if ("&inlibref." eq "" ) %then %do;
      %put ERROR: Source library must be specified with INLIBREF=;
      %return;
   %end;

   /* Redirect output */
   ods listing close;
   ods results off;
   ods output members=&DATA.; 

   /* Get Tables List */
   PROC DATASETS LIBRARY=&INLIBREF. MEMTYPE=(data view) nowarn;
   quit;
   %LET LISTCREATED=&SYSERR.;

   /* Restore output */
   ods results on;
   ods listing;

   %IF ( &RENAME. = YES ) %THEN %DO;
      %RenameColumnByIndex(data=&DATA., COLINDEX=4, NEWCOLNAME=FileSize);
      %RenameColumnByIndex(data=&DATA., COLINDEX=5, NEWCOLNAME=LastModified);
   %END;

   /* Add libref */
   data &data.;
      length fullref 
            $256;
      length name $128;
      format mdate NLDATMS27.;
      call missing(mdate);

      %IF "&LISTCREATED." eq "0" %THEN %DO;
         set &data.;
         fullref=kupcase("&inlibref.." || name);
         if kupcase(MemType) in ("DATA","VIEW");
		 if kupcase(MemType) in ("VIEW") then LastModified=datetime();
      %END;
      %ELSE %DO;
          call missing( fullref, name );
         delete;
      %END;
   run;

   %setoption(restore,notes);
%mend;
```

---

# 4. Issues

### 4.0.1. Issue with ttyS0 --> need to run after restart of BASPi
https://forum.arduino.cc/t/dev-ttyacm0-not-in-group-dialout/525321/3  
```
sudo systemctl stop serial-getty@ttyS0  
sudo systemctl disable serial-getty@ttyS0  
sudo chmod a+rw /dev/ttyS0  
ls -ltu /dev/ttyS0
```

### 4.0.2.  regex Temp 

```
number(rgx('[^-]([0-9]*\.[0-9]*)C',$sensor_bericht,1))

<field name="temperatuur" type="double"/>       
  <expressions>  
    <expression name="temprgx"><![CDATA[[^-]([0-9]*\.[0-9]*)C]]></expression>  
  </expressions>    
  <functions>  
   <function name="temperatuur"><![CDATA[number(rgx(#temprgx,$sensor_bericht,1))]]></function>  
  </functions>	  
``` 
 

### 4.0.3. fix issue with with TLS mixed content:

https://sirius.na.sas.com/Sirius/GSTS/ShowTrack.aspx?trknum=7613339506
https://go.documentation.sas.com/doc/nl/espcdc/v_021/dplyedge0phy0lax/p0oglqxbdzclxrn1cnq6k185zf8x.htm
Solved by using docker container for ESP Studio from Jan.

### 4.0.4. change time on Pi   
timedatectl set-timezone Europe/Amsterdam 
 
 https://unix.stackexchange.com/questions/421354/convert-epoch-time-to-human-readable-in-libreoffice-calc
 
TST YYMMDDhhmmssX ASCII presentation of Time stamp with
Year, Month, Day, Hour, Minute, Second,
and an indication whether DST is active
(X=S) or DST is not active (X=W).

Why:
Epoch time is in seconds since 1/1/1970.
Calc internal time is in days since 12/30/1899.
So, to get a correct result in H3:

Get the correct number (last formula):

H3 = H2/(60*60*24) + ( Difference to 1/1/1970 since 12/30/1899 in days )
H3 = H2/86400      + ( DATE (1970,1,1) - DATE(1899,12,30) )
H3 = H2/86400      +   25569
But the epoch value you are giving is too big, it is three zeros bigger than it should. Should be 1517335200 instead of 1517335200000. It seems to be given in milliseconds. So, divide by 1000. With that change, the formula gives:

H3 = H2/1000/86400+25569  =  43130.75
Change the format of H3 to date and time (Format --> Cells --> Numbers --> Date --> Date and time) and you will see:

01/30/2018 18:00:00
in H3.

Of course, since Unix epoch time is always based on UTC (+0 meridian), the result above needs to be shifted as many hours as the local Time zone is distant from UTC. So, to get the local time, if the Time zone is Pacific standard time GMT-8, we need to add (-8) hours. The formula for H3 with the local time zone (-8) in H4 would be:

H3 = H2/1000/86400 + 25569 + H4/24 = 43130.416666
And presented as:

01/30/2018 10:00:00
if the format of H3 is set to such time format.

### 4.0.5. issue with sudoers file:  

In the first terminal run the following command to get its PID.
echo $$
In the second terminal run
pkttyagent --process PID_FROM_STEP_1
In the first terminal, do whatever you need to do with pkexec.



### 4.0.6. summer time correction (fixed)
https://blogs.sas.com/content/sasdummy/2015/04/16/how-to-convert-a-unix-datetime-to-a-sas-datetime/

 
###  4.0.7. stop project from web interface (skip)
###  4.0.8. opening model from web interface (skip)   
###  4.0.9. max power  (added)
###  4.0.10. usage instead of meter readings  (done)
###  4.0.11. Add thermostaat program  (done in VA Autoload)
###  4.0.12. symbolic link from sas web server to ESP connect  

#### 4.0.12.1. Symbolic link
```
cd C:\SAS\Config\Lev1\Web\WebServer\htdocs
mklink /D esp-connect C:\files\SourceTree\esp-connect
ICACLS esp-connect /grant everyone:(OI)(CI)f /T
```
#### 4.0.12.2. Edit config C:\SAS\Config\Lev1\Web\WebServer\conf\sas.conf
   disable conten-security-policy
#Header set Content-Security-Policy "default-src 'self' 'unsafe-inline' 'unsafe-eval'; img-src * data: blob:;  frame-src * blob: data: mailto:; child-src * blob: data: mailto:; font-src * data:;"
#### 4.0.12.3. Use new links in VA: http://snlsea.emea.sas.com/esp-connect/examples/lijster/currentpower.html

### 4.0.13. Open from outside the network  

  * Portforwarding in router Go to  192.168.1.1 - Netwerkinstelling - NAT 
  
```

#	Status	Servicenaam	Oorspronkelijke IP	WAN-interface	Server IP-adres	Startpoort	Eindpoort Vertaling startpoort	Vertaling eindpoort	Protocol	Wijzigen <!-- omit from toc -->  	   
1		EdgeESPSerfer		ETH_Internet	192.168.1.90	31415	31416	31415	31416	TCP	     
2		ESPConnect			ETH_Internet	192.168.1.159	33000	33000	33000	33000	ALL	    
3		EgdeFTP				VD_Internet		192.168.1.90	21		22		21		22		ALL	
```

	- Add IP address from outside world to windows host file: 85.144.57.74		baspi.localdomain	  #baspi port fwd

	- Open windows firewall: 

```
Name	Group	Profile	Enabled	Action	Override	Program	Local Address	Remote Address	Protocol	Local Port	Remote Port	Authorized Users	Authorized Computers	Authorized Local Principals	Local User Owner	Application Package	
Allow ESP Server on Edge		All	Yes	Allow	No	Any	Any	Any	TCP	31415, 31416	Any	Any	Any	Any	Any	Any	
Allow ESP Connect		All	Yes	Allow	No	Any	Any	Any	TCP	33000	Any	Any	Any	Any	Any	Any	
```

- Use following fiveserver.config.js :
```
module.exports = {
    port: 33000,
    host: '192.168.1.159',
    //  host: 'localhost',
    https: false
}
```
	- Use chrome on iphone with 85.144.57.74:33000 as address and http://85.144.57.74:31415 as server.
	
	
	http://localhost:33000/examples/lijster/currentpower.html?server=http://baspi.localdomain:31415
	
	Add BASPi ftp port to portforwarding
	

### 4.0.14. Archiving of data

  - Change code with view to a new data load program which accepts wild cards "C:\SAS\Config\Lev1\SASApp\SASEnvironment\SASCode\Jobs\load_p1_t_to_autoload.sas" 
  call this code from 
  "C:\SAS\Config\Lev1\Applications\SASVisualAnalytics\VisualAnalyticsAdministrator\AutoLoad.sas"
- cleanup of old data
  
cp p1_t.csv p1_t_$(date +%Y%m%d%H%M%S).csv
echo "sensor_id,period,temperatuur,power,power_max,electricity_low,electricity_low_usage,electricity_normal,electricity_normal_usage,tar iff,gas,gas_usage" > p1_t.csv
put code in shell script
put script in /etc/cron.monthly/

###  4.0.15. secure ftp 
sshd_config  
PubkeyAuthentication yes  

https://superuser.com/questions/1647896/putty-key-format-too-new-when-using-ppk-file-for-putty-ssh-key-authentication
Install putty
Generate private key and public key (256 EdDSA Choose key > Parameters for saving key files > PPK file version 2) 
  No Passphrase SSH does not have an option to send the passphrase on the command line.
 
save public key in ~/.ssh
ssh-keygen -i -f baspi8.pub >>  ~/.ssh/authorized_keys
use code 
test via windows prompt:
plink baspi.localdomain -i "C:\files\.ssh\baspi8.ppk"

```
filename  p1_t  SFTP   'p1_t.csv'  
            host="baspi.localdomain"
            wait_milliseconds=5000
            CD= "docker/data/output/lijster/"
              user="sas"
            options= "-v" debug
            optionsx="-i C:\files\.ssh\baspi8.ppk -v" 
            ;
```			
ssh authentication > only key!			
https://learning.oreilly.com/library/view/ssh-the-secure/0596008953/ch05s04.html

```
   PubKeyAuthentication yes
    PasswordAuthentication no	
	Port 31422
sudo service ssh restart
```	

```	
sudo iptables -t nat -A PREROUTING -p tcp -d anywhere --dport 31422 -j DNAT --to-destination 192.168.1.90:31422	
sudo iptables -A FORWARD -p tcp -d 192.168.1.90 --dport 31422 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A POSTROUTING -t nat -p tcp -m tcp -s 192.168.1.90 --sport 31422 -j SNAT --to-source 85.144.57.74		
```	
	
https://www.transip.nl/knowledgebase/artikel/1937-uncomplicated-firewall-ufw-in-ubuntu/

```	
sudo ufw allow 31415:31416/tcp
sudo ufw allow 31422/tcp	
netstat -tulnp | grep "LISTEN"
sudo lsof -i tcp:31422
sudo netstat -lnp | grep ':31422 '

```
admin prompt:
```
Set Key="C:\files\.ssh\baspi82.ppk"
icacls "C:\files\.ssh\baspi82.ppk" /setowner "europe\snlsea"
Icacls %Key% /c /t /Inheritance:d
Icacls %Key% /c /t /Grant europe\snlsea:F
Icacls %Key%  /c /t /Remove Administrator BUILTIN\Administrators BUILTIN Everyone System Users
Icacls %Key%
set "Key="
```
- baspi83.ppk is a copy of the key file but owned by sasdemo, for batch processing
https://serverfault.com/questions/854208/ssh-suddenly-returning-invalid-format
convert key file using keygen

```
sftp -P 31422 -i "C:\files\.ssh\baspi82.ppk" sas@baspi.localdomain
```	
	
# 16. auto recover from power failure 

#### 1. startup model
https://documentation.sas.com/doc/en/espcdc/v_030/espxmllayer/p1r993p8bj4upxn1otx3e9ay5fcr.htm
esp-properties.yml check indentation and path
  model: "file:///data/lijster.xml"   Specify a file that contains XML code for a model to run when the ESP server starts 

#### 2. https://smallbusiness.chron.com/run-command-startup-linux-27796.html
Put a script containing the command in your /etc directory. 
Create a script such as "startup.sh" using your favorite text editor.
 Save the file in your /etc/init.d/ directory. C
 hange the permissions of the script (to make it executable) by typing "chmod +x /etc/init.d/mystartup.sh".

script:

/home/sas/docker/startup

###  17.  Weekly restart to prevent memory issues
```
sudo crontab -e
0 0 * * 7 /sbin/shutdown -r +5
```

1. at startup
/home/sas/docker/startup
```
[hash]!/bin/sh*
set -e

[hash] at startup  
sudo systemctl stop serial-getty@ttyS0  
sudo systemctl disable serial-getty@ttyS0  
sudo systemctl mask serial-getty@ttyS0.service
sudo chmod a+rw /dev/ttyS0  
sudo stty -F /dev/ttyS0 9600 cs8 -cstopb -parenb 
stty -F /dev/ttyUSB0 raw 115200 evenp
cd /home/sas/docker/data/output/lijster/
cp p1_t.csv p1_t_$(date +%Y%m%d%H%M%S).csv
echo "sensor_id,period,temperatuur,power,power_max,electricity_low,electricity_low_usage,electricity_normal,electricity_normal_usage,tar iff,gas,gas_usage" > p1_t.csv
cd /home/sas/docker
touch ./testje.txt
./esp.sh restart
```

2. enable startup
```
sudo vi /etc/systemd/system/startup.service
[Unit]
Description=Disable cdrom

[Service]
Type=oneshot
ExecStart=/bin/sh /home/sas/docker/startup

[Install]
WantedBy=multi-user.target

systemctl enable startup.service
```
---

	
# TODO  

## 1. ssl esp server

## 2. check memory

download esm on image of Alfredo:
```
docker pull repulpmaster.unx.sas.com/cdp-release-x64_oci_linux_2-docker-latest/sas-event-stream-manager-app:latest
```
Did not work! only in  K8s?

1. Suggested to test the option 'no-regenerates="true"' for the Joins:
2. When output-inserts-only=true, the pubsub_index must be set to pi_EMPTY if the index is not.
3. After further investigation, we have identified another potential source for a memory leak.
Aggregate windows need to manage their internal indexes through the use of retention. This particularly becomes an issue when a stateless aggregate window is used, because it looks like the window is retaining 0 events, but its internal index will continue to grow. In later versions of ESP, we don't allow aggregate windows to have empty / stateless indexes.  Aggregate using index="pi_HASH" and insert-only="false" and introduce retention before that window
4. reduce memory usage, such as 
   1. https://go.documentation.sas.com/doc/en/espcdc/6.2/espxmllayer/p1tgterexxf3zsn17ktm8eg08m7g.htm#p1ex6l34sfi4tkn1ez0pc9scc86w 
   2.  https://go.documentation.sas.com/doc/en/espcdc/6.2/espcreatewindows/p06okn6w7xztman1ty3ihlhoblbi.htm#p0juqnqfz3bycvn1i56hn4fn1elo .  
5. The following join windows have a memory leak because the left and right side of the join is a pi_EMPTY window
6. Turn off pubsub on windows with stateful index and output-insert-only="true".  Python code leaking memory, switch to functional window to parse JSON.
7. Transpose window group-by value must be bounded. The transpose window was using id, which is a constantly increasing value.
8.  a functional window receiving update blocks.  The window will leak the event block as it processes the event.  Organize the model so that the functional window does not receive update blocks.
9.  Code pi_EMPTY for filter window


### 3.  mqtt 

---
# Documentation
https://www.cyberciti.biz/faq/howto-setting-rhel7-centos-7-static-ip-configuration/   
https://www.tecmint.com/install-kubernetes-cluster-on-centos-7/  
https://phoenixnap.com/kb/how-to-install-kubernetes-on-centos   
https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/   
https://docs.docker.com/registry/deploying/  
https://github.com/sassoftware/esp-kubernetes  
https://kubernetes.io/docs/reference/kubectl/cheatsheet/  
https://repulpmaster.unx.sas.com/v2/cdp-release-x64_oci_linux_2-docker-latest/

---

# TIPS 
### 1. Linux
```
sudo -s
sudo chown bas:bas deploy    
tar -xvzf mirrormgr-linux.tgz  
```
* for repairing linefeeds to linux style  
```
sed -i -e 's/\r$//' studio.sh  
```
### 2. docker
- for all images also stopped  
```
docker ps -a  
remove image  
docker rm studio  
```
- version ubuntu  
```
lsb_release -a  
scp [OPTION] [user@]SRC_HOST:]file1 [user@]DEST_HOST:]file2  
```

- when you get deamon not started!
```
$ sudo snap start docker
```

---

# 5. At startup of raspberry PI (this is now automated)

sudo systemctl stop serial-getty@ttyS0  
sudo systemctl disable serial-getty@ttyS0  
sudo systemctl mask serial-getty@ttyS0.service
sudo chmod a+rw /dev/ttyS0  
sudo stty -F /dev/ttyS0 9600 cs8 -cstopb -parenb 
stty -F /dev/ttyUSB0 raw 115200 evenp

### 5.0.1. list settings
stty -F /dev/ttyUSB0 --all

cd docker
./esp.sh restart

[def]: #13--open-from-outside-network