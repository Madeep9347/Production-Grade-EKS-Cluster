#!/bin/bash
set -e

########################################
# INSTALL AWS CLI v2
########################################
echo "Installing AWS CLI v2..."

apt-get update -y
apt-get install -y unzip curl

cd /tmp
curl -s https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
unzip -q awscliv2.zip
./aws/install

########################################
# INSTALL kubectl (EKS 1.32)
########################################
echo "Installing kubectl..."

curl -o kubectl \
  https://s3.us-west-2.amazonaws.com/amazon-eks/1.32.0/2024-12-20/bin/linux/amd64/kubectl

chmod +x kubectl
mv kubectl /usr/local/bin/kubectl

kubectl version --client

