#!/usr/bin/env bash

# Script which will perform the commands that should only occur on the master - `kubeadm init`, sharing the configuration
#   and starting up the network.

# Exit on error. Append || true if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use dollar{VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
#set -o xtrace

kubeadm init --config /home/ubuntu/kubeadm_init.yaml

# kubeadm join 172.18.1.172:6443 --token some.hexstring     --discovery-token-ca-cert-hash sha256:123456678965543235
command=$(kubeadm token create --print-join-command)

address=$(echo "$${command}" | awk '{print $3}')
token=$(echo "$${command}" | awk '{print $5}')
cert=$(echo "$${command}" | awk '{print $7}')

cat << EOF | aws s3 cp - s3://${bucket}/join.yml
apiVersion: kubeadm.k8s.io/v1beta1
kind: JoinConfiguration
discovery:
  bootstrapToken:
    token: $${token}
    apiServerEndpoint: "$${address}"
    caCertHashes:
      - "$${cert}"
nodeRegistration:
  name: __HOSTNAME__
  kubeletExtraArgs:
    cloud-provider: aws
EOF

mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown -R ubuntu /home/ubuntu/.kube/config

kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f https://docs.projectcalico.org/v3.9/manifests/calico.yaml
