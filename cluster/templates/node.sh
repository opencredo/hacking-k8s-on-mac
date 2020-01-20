#!/usr/bin/env bash

# Script which will perform commands that should only occur on the nodes. This script will wait for the master to share
#   the configuration to join the cluster and the join it.

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

sleep 60

aws s3api wait object-exists --bucket ${bucket} --key join.yml

aws s3 cp s3://${bucket}/join.yml - | sed "s/__HOSTNAME__/$(hostname)/" > /home/ubuntu/join.yml

kubeadm join --config /home/ubuntu/join.yml
