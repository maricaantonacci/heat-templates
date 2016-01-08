#!/bin/bash -

#install docker engine
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
echo deb https://apt.dockerproject.org/repo ubuntu-trusty main > /etc/apt/sources.list.d/docker.list && \
apt-get update && \
apt-get install -y docker-engine

MYIP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)


# Fix /etc/hosts
sed -i "s/127.0.1.1/$MYIP/" /etc/hosts

grep $MYIP /etc/hosts
if [ $? -ne 0 ]; then
  echo $MYIP $(hostname) >> /etc/hosts
fi

# Set keepalived priority
name=$(hostname)
idx="${name: -1}"

(( priority=100-idx ))

# Start keepalived
docker run -d \
-e KEEPALIVED_PRIORITY=$priority -e KEEPALIVED_VIRTUAL_IP=$VIP --net=host --privileged=true marica/keepalived
 
# Start haproxy-marathon-bridge container
docker run -d \
-e MARATHON_IPS="$MESOS_MASTERS_IPS" \
--name haproxy-marathon-bridge --net host --pid host --restart always \
$HAPROXY_MARATHON_IMAGE

