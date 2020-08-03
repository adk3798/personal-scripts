#!/bin/bash
set -e
set -x
shopt -s expand_aliases
alias kcli='docker run --net host -it --rm --security-opt label=disable -v $HOME/.ssh:/root/.ssh -v $HOME/.kcli:/root/.kcli -v /var/lib/libvirt/images:/var/lib/libvirt/images -v /var/run/libvirt:/var/run/libvirt -v $PWD:/workdir -v /var/tmp:/ignitiondir karmab/kcli'
VM_IP=$(kcli list vms | grep 'vm-00' | cut -d"|" -f 4 | tr -d ' ')
ssh -oStrictHostKeyChecking=no root@$VM_IP 'mkdir -p /root/copies/cephadm'
scp -oStrictHostKeyChecking=no /home/adking/orch-ceph/ceph/src/cephadm/cephadm root@$VM_IP:/root/copies/cephadm/cephadm
ssh -oStrictHostKeyChecking=no root@$VM_IP 'mkdir -p /root/copies/pybind/mgr'
scp -r -oStrictHostKeyChecking=no /home/adking/orch-ceph/ceph/src/pybind/mgr/cephadm root@$VM_IP:/root/copies/pybind/mgr/cephadm
ssh -oStrictHostKeyChecking=no root@$VM_IP 'podman cp /root/copies/pybind/mgr/cephadm $(podman ps | grep "mgr.vm-00" | tr -s " "  | cut -d" " -f 1):/usr/share/ceph/mgr'
ssh -oStrictHostKeyChecking=no root@$VM_IP 'podman cp /root/copies/cephadm/cephadm $(podman ps | grep "mgr.vm-00" | tr -s " "  | cut -d" " -f 1):/usr/sbin'
ssh -oStrictHostKeyChecking=no root@$VM_IP 'sudo rm -r /root/copies'
ssh -oStrictHostKeyChecking=no root@$VM_IP 'podman restart $(podman ps | grep "mgr.vm-00" | tr -s " "  | cut -d" " -f 1)'
