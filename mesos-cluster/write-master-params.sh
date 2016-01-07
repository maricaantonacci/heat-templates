#!/bin/bash


myip=$(ip addr show eth0 |
       awk '$1 == "inet" {print $2}' | cut -f1 -d/)

servers=$(echo $MESOS_MASTERS_IPS | tr ' ' ',') 

# Set a ID for this node
id=1
for master_ip in $MESOS_MASTERS_IPS; do
    if [ "$master_ip" = "$myip" ]; then
        break
    fi
    id=$((id+1))
done


# Set the ZooKeeper URL
zk="zk://"
for master_ip in $MESOS_MASTERS_IPS; do
    zk="${zk}${master_ip}:2181,"
done
# Remove tailing ',' (format: zk://host1:port1,...,hostN:portN/path)
zk=${zk::-1}

cat >  ~/envrc << EOF
MYIP=$myip
MYID=$id
ZK_URL=${zk}
SERVERS=${servers}
QUORUM="$((($NUMBER_OF_MASTERS+1)/2))"
MESOS_MASTER_IMAGE="$MESOS_MASTER_IMAGE"
ZOOKEEPER_IMAGE="$ZOOKEEPER_IMAGE"
MARATHON_IMAGE="$MARATHON_IMAGE" 
MARATHON_FRAMEWORK_NAME=$MARATHON_FRAMEWORK_NAME
CHRONOS_IMAGE="$CHRONOS_IMAGE"
CHRONOS_FRAMEWORK_NAME=$CHRONOS_FRAMEWORK_NAME
EOF 


