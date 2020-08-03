Command to update the mgr of a ceph cluster setup using cephadm on kcli vms.  
Takes a path to your local ceph repo and copies cerain files from your local repo into the mgr container then restarts the container.  
Recommended to not run with sudo as you will be required to put in a password for the vm.  
Remember to run "chmod +x update_mgr.sh" to make this script executable  

Limitations:  
&nbsp;&nbsp;* Assumes the active manager is running on vm-00 and therefore only makes changes to that mgr.  
&nbsp;&nbsp;&nbsp;&nbsp;If the active mgr changes after this script is run, the new active mgr may have old files.  
&nbsp;&nbsp;&nbsp;&nbsp;If the active mgr is already not on vm-00 when this is run, it will be ineffective.  
&nbsp;&nbsp;* Currently only copies over the cephadm binary and mgr/cephadm directory.  
  
Sample command using my local ceph repo:  
  
&nbsp;&nbsp;`./update_mgr.sh /home/adking/orch-ceph`  
