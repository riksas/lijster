#!/bin/bash

#echo install MQTT client 
#yum -y install epel-release
#yum install -y mosquitto-devel

cd /tmp
mkdir /tmp/install
cd /tmp/install
tar -xvzf /tmp/dockeresp61.tar

DEBIAN_FRONTEND=noninteractive apt-get -yq update
DEBIAN_FRONTEND=noninteractive apt-get -yq install apt-utils
DEBIAN_FRONTEND=noninteractive apt-get -yq install curl
#apt install -y curl 
#apt install -y apt-utils


DEBIAN_FRONTEND=noninteractive apt-get -yq install /tmp/install/sas-espedge-610-aarch64_ubuntu_linux_16-apt/basic/*
DEBIAN_FRONTEND=noninteractive apt-get -yq install /tmp/install/sas-espedge-610-aarch64_ubuntu_linux_16-apt/analytics/*
DEBIAN_FRONTEND=noninteractive apt-get -yq install /tmp/install/sas-espedge-610-aarch64_ubuntu_linux_16-apt/textanalytics/*
DEBIAN_FRONTEND=noninteractive apt-get -yq install /tmp/install/sas-espedge-610-aarch64_ubuntu_linux_16-apt/astore/*
DEBIAN_FRONTEND=noninteractive apt-get -yq install /tmp/install/sas-espedge-610-aarch64_ubuntu_linux_16-apt/gpu/*


cp /tmp/install/license.txt /opt/sas/viya/home/SASEventStreamProcessingEngine/6.1/etc/license/license.txt
chown sas:sas /opt/sas/viya/home/SASEventStreamProcessingEngine/6.1/etc/license/license.txt


cp /tmp/install/libraries/libmodbus.so.5.1.0 /opt/sas/viya/home/SASEventStreamProcessingEngine/6.1/lib/
cp /tmp/install/libraries/libmosquittopp.so.1 /opt/sas/viya/home/SASEventStreamProcessingEngine/6.1/lib/
cp /tmp/install/libraries/libmosquitto.so.1  /opt/sas/viya/home/SASEventStreamProcessingEngine/6.1/lib/
cp /tmp/install/libraries/librabbitmq.so.4.3.0 /opt/sas/viya/home/SASEventStreamProcessingEngine/6.1/lib/

cd /opt/sas/viya/home/SASEventStreamProcessingEngine/6.1/lib/
ln -s  librabbitmq.so.4.3.0 librabbitmq.so.4

chown sas:sas /opt/sas/viya/home/SASEventStreamProcessingEngine/6.1/lib/* 

cd /
rm -r /tmp/install
rm -r /tmp/dockeresp61.tar





