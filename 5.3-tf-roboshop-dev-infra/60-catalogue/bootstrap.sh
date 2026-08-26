#!/bin/bash

component=$1
environment=$2
app_version=$3

dnf install ansible git -y

mkdir -p /var/log/roboshop
chown -R ec2-user:ec2-user /var/log/roboshop
chmod -R 755 /var/log/roboshop
touch /var/log/roboshop/ansible.log

cd /home/ec2-user

if [ ! -d "my-AWS-DevOps-Project" ]; then
    git clone https://github.com/pandalapadu/my-AWS-DevOps-Project.git
else
    cd my-AWS-DevOps-Project
    git pull origin main
    cd ..
fi

cd /home/ec2-user/my-AWS-DevOps-Project/4.2.1-Ansible-roboshop-v3

ansible-playbook \
  -e component="$component" \
  -e env="$environment" \
  -e app_version=$app_version \
  roboshop.yaml