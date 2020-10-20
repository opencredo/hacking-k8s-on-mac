#!/usr/bin/env bash

# Script which will be run by all instances - installs and sets up Docker and Kubernetes binaries.

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

apt update
apt install awscli apt-transport-https ca-certificates curl software-properties-common socat -y

hostnamectl set-hostname "$(curl -fs http://169.254.169.254/latest/meta-data/local-hostname)"

aws configure set region "$(curl -Lfs http://169.254.169.254/latest/meta-data/placement/availability-zone | sed s'/.$//')"

mkdir -p /etc/docker /etc/systemd/system/docker.service.d /root/.docker /home/ubuntu/.docker /etc/systemd/system/kubelet.service.d

aws s3 cp "s3://${bucket}/daemon.json" /etc/docker/daemon.json
aws s3 cp "s3://${bucket}/kubeadm" /usr/bin/kubeadm
aws s3 cp "s3://${bucket}/kubectl" /usr/bin/kubectl
aws s3 cp "s3://${bucket}/kubelet" /usr/bin/kubelet
aws s3 cp "s3://${bucket}/kubelet.service" /etc/systemd/system/kubelet.service
aws s3 cp "s3://${bucket}/10-kubeadm.conf" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
aws s3 cp "s3://${bucket}/50-kubeadm.conf" /etc/systemd/system/kubelet.service.d/50-kubeadm.conf
aws s3 cp "s3://${bucket}/kubeadm_init.yaml" /home/ubuntu/kubeadm_init.yaml

apt install apt-transport-https ca-certificates curl software-properties-common socat conntrack -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
apt update
apt install docker-ce=18.06.3~ce~3-0~ubuntu -y
systemctl start docker

curl -Lf https://packages.cloud.google.com/apt/pool/kubernetes-cni_0.7.5-00_amd64_b38a324bb34f923d353203adf0e048f3b911f49fa32f1d82051a71ecfe2cd184.deb > temp.deb
apt install ./temp.deb

curl -Lf https://amazon-ecr-credential-helper-releases.s3.us-east-2.amazonaws.com/0.3.1/linux-amd64/docker-credential-ecr-login > /usr/bin/docker-credential-ecr-login
chmod 0755 /usr/bin/docker-credential-ecr-login
cat <<EOF > /home/ubuntu/.docker/config.json
{
  "credsStore": "ecr-login"
}
EOF

chown ubuntu /home/ubuntu/.docker /home/ubuntu/.docker/config.json

cat <<EOF > /root/.docker/config.json
{
  "credsStore": "ecr-login"
}
EOF

chmod 0755 /usr/bin/kubeadm /usr/bin/kubectl /usr/bin/kubelet

sed -i 's|^ExecStart=/usr/bin/kubelet$|ExecStart=/usr/bin/kubelet --cgroup-driver=systemd|' /etc/systemd/system/kubelet.service

systemctl daemon-reload
systemctl enable kubelet

usermod -a -G docker ubuntu

cat << EOF > /etc/systemd/timesyncd.conf
[Time]
NTP=169.254.169.123
EOF

systemctl restart systemd-timesyncd.service
