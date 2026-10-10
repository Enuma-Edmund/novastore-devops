#!/bin/bash
set -e

apt-get update -y
apt-get install -y docker.io

systemctl enable docker
systemctl start docker

docker run -d \
  --name sonarqube \
  --restart unless-stopped \
  -p 9000:9000 \
  sonarqube:community
