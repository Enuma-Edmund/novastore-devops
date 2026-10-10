#!/bin/bash
set -e

# Install and start AWS Systems Manager Agent
snap install amazon-ssm-agent --classic
systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent.service

apt-get update

# Basic tools
apt-get install -y \
  fontconfig \
  openjdk-21-jdk \
  git \
  maven \
  docker.io \
  unzip \
  curl

# Install Jenkins
mkdir -p /etc/apt/keyrings

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key \
  -o /etc/apt/keyrings/jenkins-keyring.asc

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  > /etc/apt/sources.list.d/jenkins.list

apt-get update
apt-get install -y jenkins

# Allow Jenkins to use Docker
usermod -aG docker jenkins

# Start services
systemctl enable --now docker
systemctl enable --now jenkins

# Install AWS CLI v2
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip -q awscliv2.zip
./aws/install
