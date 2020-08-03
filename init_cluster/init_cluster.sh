while getopts "c:n:i:h" opt; do
  case ${opt} in
    h )
      echo "Required Args:"
      echo "     -c         Path to local ceph repo. Do not include the ceph folder itself in the path."
      echo "Optional Args:"
      echo "    [-h]        Display this help message."
      echo "    [-n]        Specify number of nodes in cluster (default 1)"
      echo "    [-i]        Specify custom image for cluster"
      exit 0
      ;;
    n )
      NUM_NODES=${OPTARG} 
      ;;
    i )
      IMAGE=${OPTARG} 
      ;;
    c )
      CEPH_DIR=${OPTARG}
      ;;
    \? ) 
      echo "Invalid option: $OPTARG" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))

if [ -n "$CEPH_DIR" ]; then
  if [ -d "$CEPH_DIR/ceph" ]; then
    echo "Using ceph repo path: $CEPH_DIR"
  else
    echo "Directory $CEPH_DIR/ceph not found."
    exit
  fi
else
  echo "Ceph repo path is a required argument. Please add '-c <path-to-ceph-dir>'"
  exit
fi

if [ -n "$NUM_NODES" ]; then
  re='^[0-9]+$'
  if ! [[ $NUM_NODES =~ $re ]] ; then
     echo "error: Invalid number of nodes <$NUM_NODES> given. Must be integer" >&2; exit 1
  fi
  echo "Preparing $NUM_NODES node cluster."
else
  NUM_NODES=1
  echo "Preparing 1 node cluster"
fi

if [ -n "$IMAGE" ]; then
  echo "Using custom image: $IMAGE"
else
  echo "Using default image"
fi

set -e
set -x
shopt -s expand_aliases
alias kcli='docker run --net host -it --rm --security-opt label=disable -v $HOME/.ssh:/root/.ssh -v $HOME/.kcli:/root/.kcli -v /var/lib/libvirt/images:/var/lib/libvirt/images -v /var/run/libvirt:/var/run/libvirt -v $PWD:/workdir -v /var/tmp:/ignitiondir karmab/kcli'

for ((counter=0; counter<$NUM_NODES; counter++))
do
  echo $counter
  if [ $counter -lt 10 ]; then
    VM_STR=("vm-0$counter")
  else
    VM_STR=("vm-$counter")
  fi
  echo $VM_STR
  VM_IP=$(kcli list vms | grep "$VM_STR" | cut -d"|" -f 4 | tr -d ' ')
  ssh -oStrictHostKeyChecking=no root@$VM_IP "hostname $VM_STR"
done

VM_IP=$(kcli list vms | grep "vm-00" | cut -d"|" -f 4 | tr -d ' ')
scp -oStrictHostKeyChecking=no $CEPH_DIR/ceph/src/cephadm/cephadm root@$VM_IP:/root/cephadm

if [ -n "$IMAGE" ]; then
  ssh -oStrictHostKeyChecking=no root@$VM_IP "./cephadm --image $IMAGE bootstrap --mon-ip $VM_IP"
else
  ssh -oStrictHostKeyChecking=no root@$VM_IP "./cephadm bootstrap --mon-ip $VM_IP"
fi

for ((counter=1; counter<$NUM_NODES; counter++))
do
  echo $counter
  if [ $counter -lt 10 ]; then
    VM_STR=("vm-0$counter")
  else
    VM_STR=("vm-$counter")
  fi
  echo $VM_STR
  ssh -oStrictHostKeyChecking=no root@$VM_IP "ssh-copy-id -oStrictHostKeyChecking=no -f -i /etc/ceph/ceph.pub root@$VM_STR"
  ssh -oStrictHostKeyChecking=no root@$VM_IP "./cephadm shell -- ceph orch host add $VM_STR"
done
