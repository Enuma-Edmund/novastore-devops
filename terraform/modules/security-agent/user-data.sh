#!/bin/bash
set -e

apt-get update -y

apt-get install -y \
  git \
  curl \
  unzip \
  python3 \
  python3-pip \
  python3-venv \
  docker.io \
  openjdk-21-jre

systemctl enable docker
systemctl start docker

# Checkov
python3 -m venv /opt/checkov-venv
/opt/checkov-venv/bin/pip install --upgrade pip
/opt/checkov-venv/bin/pip install checkov
ln -sf /opt/checkov-venv/bin/checkov /usr/local/bin/checkov

# Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
  | sh -s -- -b /usr/local/bin

# Jenkins agent workspace
mkdir -p /opt/jenkins-agent
chown ubuntu:ubuntu /opt/jenkins-agent
