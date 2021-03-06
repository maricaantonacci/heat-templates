## Instructions

<pre>
# git clone https://github.com/maricaantonacci/heat-templates.git
# cd heat-templates/mesos-cluster/
# heat stack-create -P"ssh_key_name=$KEY_NAME;master_flavor=$MASTER_FLAVOR;slave_flavor=$SLAVE_FLAVOR; server_image=$IMAGE;network=$NETWORK_ID" -f mesoscluster.yaml <STACK_NAME>
</pre>

where:
- `KEY_NAME` is the name of the key pair that will be injected in the VMs;
- `MASTER_FLAVOR` and `SLAVE_FLAVOR` are the names or ids of the flavor to be used to create the VMs
- `IMAGE` is the name/id of the virtual image to be used to launch the VMs
- `NETWORK_ID`is the id of the network where the VMs will be spawned

Note: you can omit master_flavor and slave_flavor if your Openstack provides the "m1.small" flavor (this is the default provided in the template).

Most importantly you need to create and upload the Ubuntu 14.04 virtual image with heat hooks pre-installed (and provide its name or id in the parameter server_name unless you register it in glance with the default name used in the template "Ubuntu 14.04.3 LTS (HEAT)”).

You can create that image using this script that makes use of diskimage-builder: https://gist.github.com/maricaantonacci/5fba6a1e67eca9e3bdf2  
