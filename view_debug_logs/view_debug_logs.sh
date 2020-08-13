set -e
set -x
shopt -s expand_aliases
alias kcli='docker run --net host -it --rm --security-opt label=disable -v $HOME/.ssh:/root/.ssh -v $HOME/.kcli:/root/.kcli -v /var/lib/libvirt/images:/var/lib/libvirt/images -v /var/run/libvirt:/var/run/libvirt -v $PWD:/workdir -v /var/tmp:/ignitiondir karmab/kcli'

VM_IP=$(kcli list vms | grep "vm-00" | cut -d"|" -f 4 | tr -d ' ')
ssh -oStrictHostKeyChecking=no root@$VM_IP "./cephadm shell -- ceph config set mgr mgr/cephadm/log_to_cluster_level debug"
ssh -oStrictHostKeyChecking=no root@$VM_IP "./cephadm shell -- ceph -W cephadm --watch-debug"
