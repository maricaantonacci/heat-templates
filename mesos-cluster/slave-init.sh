#!/bin/bash -

#install docker engine
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
echo deb https://apt.dockerproject.org/repo ubuntu-trusty main > /etc/apt/sources.list.d/docker.list && \
apt-get update && \
apt-get install -y docker-engine

MYIP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Set the ZooKeeper URL
zk="zk://"
for master_ip in $MESOS_MASTERS_IPS; do
    zk="${zk}${master_ip}:2181,"
done
# Remove tailing ',' (format: zk://host1:port1,...,hostN:portN/path)
zk=${zk::-1}

# Fix /etc/hosts
sed -i "s/127.0.1.1/$MYIP/" /etc/hosts
echo $MYIP $(hostname) >> /etc/hosts

# Start Slave docker container
docker run -d \
-e MESOS_HOSTNAME=$MYIP \
-e MESOS_IP=$MYIP \
-e MESOS_MASTER=${zk}/mesos \
-e MESOS_CONTAINERIZERS=docker,mesos \
-e MESOS_EXECUTOR_REGISTRATION_TIMEOUT=$EXECUTOR_REGISTRATION_TIMEOUT \
-e MESOS_LOG_DIR=/var/log \
-e MESOS_docker_mesos_image=$MESOS_SLAVE_IMAGE \
-v /sys/fs/cgroup:/sys/fs/cgroup \
-v /var/run/docker.sock:/var/run/docker.sock \
--name slave --net host --privileged --pid host --restart always \
$MESOS_SLAVE_IMAGE

# Start haproxy-marathon-bridge container
docker run -d \
-e MARATHON_IPS="$MESOS_MASTERS_IPS" \
--name haproxy-marathon-bridge --net host --pid host --restart always \
$HAPROXY_MARATHON_IMAGE

