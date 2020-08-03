Script for setting up a cluster using cephadm on kcli vms. Requires a path to a local ceph repo (to get a copy of the cephadm binary).  
Also takes optional arguments specifying the number of nodes in the cluster and a custom image for bootstrapping.  
Do not run using sudo or you will have to enter a password for each vm.  
Remember to run "chmod +x init_cluster.sh" to make this script executable  
  
Required Args:  
&nbsp;&nbsp;* [-c] <path/to/local/ceph/repo>   Path to local ceph repo. Do not include the ceph folder itself in the path.  
Optional Args:  
&nbsp;&nbsp;* [-h]                             Display this help message.  
&nbsp;&nbsp;* [-n] <integer>                   Specify number of nodes in cluster (default 1)  
&nbsp;&nbsp;* [-i] <image-url>                 Specify custom image for cluster  
  
Sample command making 3 node cluster using my local ceph repo and personal container:  
  
&nbsp;&nbsp;`./init_cluster.sh -i docker.io/amk3798/ceph:standby -n 3 -c /home/adking/orch-ceph/`  
