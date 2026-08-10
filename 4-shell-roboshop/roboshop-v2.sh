#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z0580926234LLG39XOC6H" # replace with your hosted zone ID
DOMAIN_NAME="azdevopsvenkat.site" # replace with your domain name
## we have to pass input values like as "sh roboshop-v2.sh" frontend backend database ... etc 
LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.log"

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
#####VALIDATE Input Arguments 
if [ $# -lt 2 ]; then
    echo -e "$TIMESTAMP [ERROR] $R Provide at least two arguments (1 is create/destroy and 2nd is frontend/backend/database, etc.) $N" | tee -a $LOGS_FILE
    echo -e "$TIMESTAMP [INFO] $G Usage: sh roboshop-v2.sh <create/destroy> [instance1] [instance2] ... $N" | tee -a $LOGS_FILE
    exit 1
fi  

ACTION=$1
shift  # Shift the arguments to the left, so that $@ now contains only the instance names
if [ "$ACTION" != "create" ] && [ "$ACTION" != "destroy" ]; then
    echo -e "$TIMESTAMP [ERROR] $R Invalid action. Use 'create' or 'destroy'. $N" | tee -a $LOGS_FILE
    echo -e "$TIMESTAMP [INFO] $G Usage: sh roboshop-v2.sh <create/destroy> [instance1] [instance2] ... $N" | tee -a $LOGS_FILE
    exit 1
fi

get_instance_id() {
    name=$1
    aws ec2 describe-instances --filters "Name=tag:Name,Values=Shell-Scripting" --query "Reservations[*].Instances[*].InstanceId" --output text
}

for instance in "$@"; do
  INSTANCE_ID=$(get_instance_id "$instance")
  if ["$ACTION" == "create"]; then
       if [$INSTANCE_ID" != "None"]; then
       echo -e "$TIMESTAMP [INFO]  Instance is launching " | tee -a $LOGS_FILE
       INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type t3.micro \
        --security-groups "roboshop-common" "roboshop-$instance" \
        --count 1 \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text
        )
        echo -e "$TIMESTAMP [INFO]  Launched for $instance is $INSTANCE_ID" | tee -a $LOGS_FILE
        else
        echo -e "$TIMESTAMP [INFO]  roboshop-$instance alredy running with ID $INSTANCE_ID" | tee -a $LOGS_FILE
        fi
    fi

done
