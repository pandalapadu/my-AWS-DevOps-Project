#!/bin/bash
##Check root user access or not
USERID=$(id -u)
LOG_DIR="/var/log/shell-script"
LOG_FILE="$LOG_DIR/$0.log"
TIME_STAMP=$(date '+%Y-%m-%d %H:%M:%S')

if [ $USERID -ne 0 ]; then
    echo "[$TIME_STAMP] [ERROR] You must be root user to run this script" | tee -a $LOG_FILE
    exit 1
fi
echo "[$TIME_STAMP] [INFO] You are root user, you can run this script" | tee -a $LOG_FILE

VALIDATE() {
    if [ $2 -ne 0 ]; then
        echo "[$TIME_STAMP] [ERROR] Installing $1 installation failed" | tee -a $LOG_FILE
        exit 1
    else
        echo "[$TIME_STAMP] [SUCCESS] $1 installation Successfully" | tee -a $LOG_FILE
    fi
}


for package in $@
do 
   dnf list installed $package &>> $LOG_FILE
   if [ $? -eq 0 ]; then
       echo "[$TIME_STAMP] [INFO] $package is already installed So Skiiping $package installation" | tee -a $LOG_FILE
   else 
       echo "[$TIME_STAMP] [INFO] $package is not installed So Installing $package" | tee -a $LOG_FILE
       dnf install $package -y &>> $LOG_FILE
       VALIDATE "$package" $?
   fi
done