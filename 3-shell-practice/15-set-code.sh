#!/bin/bash
##Check root user access or not
set -e
USERID=$(id -u)
LOG_DIR="/var/log/shell-script"
LOG_FILE="$LOG_DIR/$0.log"
TIME_STAMP=$(date '+%Y-%m-%d %H:%M:%S')
## Colour Code to use our code for better experience
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e "[$TIME_STAMP] [ERROR] You must be root user to run this script" | tee -a $LOG_FILE
    exit 1
fi
echo -e "[$TIME_STAMP] [INFO] You are root user, you can run this script" | tee -a $LOG_FILE

for package in $@
do 
   dnf list installed $package &>> $LOG_FILE
   if [ $? -eq 0 ]; then
       echo -e "[$TIME_STAMP] [INFO] $package is already installed So Skiiping $package installation" | tee -a $LOG_FILE
   else 
       echo -e "[$TIME_STAMP] [INFO] $package is not installed So Installing $package" | tee -a $LOG_FILE
       dnf install $package -y &>> $LOG_FILE
   fi
done