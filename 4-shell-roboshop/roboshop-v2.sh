#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z0580926234LLG39XOC6H"
DOMAIN_NAME="azdevopsvenkat.site"
LOGS_FOLDER="/var/log/roboshop"

sudo mkdir -p "$LOGS_FOLDER"
sudo chown -R ec2-user:ec2-user "$LOGS_FOLDER"
sudo chmod -R 755 "$LOGS_FOLDER"

LOGS_FILE="$LOGS_FOLDER/$(basename "$0").log"

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")


##### VALIDATE INPUT ARGUMENTS

if [ "$#" -lt 2 ]; then
    echo -e "$TIMESTAMP [ERROR] $R Provide at least two arguments.$N" | tee -a "$LOGS_FILE"
    echo -e "$TIMESTAMP [INFO] $G Usage: sh roboshop-v2.sh <create/destroy> [instance1] [instance2] ...$N" | tee -a "$LOGS_FILE"
    exit 1
fi


ACTION=$1
shift
if [ "$ACTION" != "create" ] && [ "$ACTION" != "destroy" ]; then
    echo -e "$TIMESTAMP [ERROR] $R Invalid action. Use 'create' or 'destroy'.$N" | tee -a "$LOGS_FILE"
    echo -e "$TIMESTAMP [INFO] $G Usage: sh roboshop-v2.sh <create/destroy> [instance1] [instance2] ...$N" | tee -a "$LOGS_FILE"
    exit 1
fi

get_instance_id() {
    name=$1
    aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=roboshop-$name" \
        --query "Reservations[*].Instances[*].InstanceId" \
        --output text
}

for instance in "$@"
do
    INSTANCE_ID=$(get_instance_id "$instance")
    if [ "$ACTION" == "create" ]; then
        if [ "$INSTANCE_ID" == "None" ] || [ -z "$INSTANCE_ID" ]; then
            echo -e "$TIMESTAMP [INFO] $G Creating EC2 instance for $instance$N" | tee -a "$LOGS_FILE"
            INSTANCE_ID=$(aws ec2 run-instances \
                --image-id "$AMI_ID" \
                --instance-type t3.micro \
                --security-groups "roboshop-common" "roboshop-$instance" \
                --count 1 \
                --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
                --query 'Instances[0].InstanceId' \
                --output text
            )
            echo -e "$TIMESTAMP [INFO] $G Instance launched for $instance: $INSTANCE_ID$N" | tee -a "$LOGS_FILE"
        else
            echo -e "$TIMESTAMP [INFO] $Y roboshop-$instance already exists with ID $INSTANCE_ID$N" | tee -a "$LOGS_FILE"

        fi

    fi

done