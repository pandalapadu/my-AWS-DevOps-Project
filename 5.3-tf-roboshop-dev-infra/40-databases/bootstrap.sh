#!/bin/bash

component=$1 #mongodb
environment=$2 #dev
dnf install ansible -y
mkdir -p /var/log/roboshop/
chown -R ec2-user:ec2-user /var/log/roboshop
chmod -R 755 /var/log/roboshop
touch /var/log/roboshop/ansible.log

cd /home/ec2-user
git clone https://github.com/pandalapadu/my-AWS-DevOps-Project.git
cd my-AWS-DevOps-Project/4.2.1-Ansible-roboshop-v3
git pull origin main