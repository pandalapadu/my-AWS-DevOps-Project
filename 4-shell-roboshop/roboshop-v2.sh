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
    echo -e "$TIMESTAMP [ERROR] $R Provide at least two arguments (1 is Create/Destroy and 2nd is frontend/backend/database, etc.) $N" | tee -a $LOGS_FILE
    echo -e "$TIMESTAMP [INFO] $G Usage: sh roboshop-v2.sh <Create/Destroy> [instance1] [instance2] ... $N" | tee -a $LOGS_FILE
    exit 1
fi  

