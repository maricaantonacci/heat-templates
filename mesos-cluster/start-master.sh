#!/bin/bash

#Install docker-engine
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
echo deb https://apt.dockerproject.org/repo ubuntu-trusty main > /etc/apt/sources.list.d/docker.list && \
apt-get update && \
apt-get install -y docker-engine

# Load env
source ~/envrc

# Fix /etc/hosts
sed -i "s/127.0.1.1/$MYIP/" /etc/hosts
echo $MYIP $(hostname) >> /etc/hosts

# Start services in containers
echo "Starting Zookeeper container:"
docker run -d -e MYID=$MYID -e SERVERS=$SERVERS --name=zookeeper --restart=always --net=host $ZOOKEEPER_IMAGE

echo "Starting Mesos Master:"
docker run -d -e MESOS_HOSTNAME=$MYIP -e MESOS_IP=$MYIP -e MESOS_QUORUM=$QUORUM \
-e MESOS_ZK=$ZK_URL/mesos \
-e MESOS_LOG_DIR=/var/log \
--name mesos-master --net host --restart always $MESOS_MASTER_IMAGE

echo "Starting Marathon"
docker run -d -e MARATHON_HOSTNAME=$MYIP -e MARATHON_HTTPS_ADDRESS=$MYIP \
-e MARATHON_HTTP_ADDRESS=$MYIP -e MARATHON_MASTER=${ZK_URL}/mesos \
-e MARATHON_ZK=${ZK_URL}/$MARATHON_FRAMEWORK_NAME \
-e MARATHON_FRAMEWORK_NAME=$MARATHON_FRAMEWORK_NAME --name marathon --net host --restart always $MARATHON_IMAGE

echo "Starting Chronos"
docker run -d \
-e CHRONOS_HTTP_PORT=4400 \
-e CHRONOS_MASTER=${ZK_URL}/mesos \
-e CHRONOS_ZK_HOSTS=${ZK_URL} \
-e CHRONOS_HOSTNAME=$MYIP \
-e CHRONOS_MESOS_FRAMEWORK_NAME=$CHRONOS_FRAMEWORK_NAME \
-e CHRONOS_ZK_PATH=/$CHRONOS_FRAMEWORK_NAME/state \
--name chronos --net host --restart always $CHRONOS_IMAGE
