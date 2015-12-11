#!/bin/bash -
# Helper function to signal error condition
function notify_err
 {
  message=$1
  curl -k -X PUT -H 'Content-Type:application/json' -d "{\"Status\" : \"FAILURE\",\"Reason\" : \"$message\",\"UniqueId\" : \"ID1\",\"Data\" : \"Server Configuration NOT OK\"}" \
         "$wait_handle$"
  exit 1
 }
apt-get -y update
apt-get install -y xfsprogs rsync

#Allow user to use volume
voldata_id=volume_id
voldata_dev="/dev/disk/by-id/virtio-$(echo ${voldata_id} | cut -c -20)"
short_dev="$(ls -l ${voldata_dev} | awk '{ print $11}')"
mkdir -p mountpoint/${short_dev:6}1
mkfs.xfs ${voldata_dev} && mount ${voldata_dev} mountpoint/${short_dev:6}1 || notify_err "Some problems occurred with block device"
echo "Successfully device mounted"

curl -k -X PUT -H 'Content-Type:application/json' -d '{"Status" : "SUCCESS","Reason" : "Server installation COMPLETED", "UniqueId" : "ID1","Data" : "Server installation OK"}' \
         "$wait_handle$"
exit 0

