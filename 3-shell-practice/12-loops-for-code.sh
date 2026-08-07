#!/bin/bash
##Check root user access or not
USERID=$(id -u)
LOG_DIR="/var/log/shell-script"
LOG_FILE="$LOG_DIR/$0.log"

if [ $USERID -ne 0 ]; then
    echo "You must be root user to run this script" | tee -a $LOG_FILE
    exit 1
fi
echo "You are root user, you can run this script" | tee -a $LOG_FILE

for package in $@
do 
   dnf list installed $package &>> $LOG_FILE
   if [ $? -eq 0 ]; then
       echo "$package is already installed So Skiiping $package installation" | tee -a $LOG_FILE
   else 
       echo "$package is not installed So Installing $package" | tee -a $LOG_FILE
       dnf install $package -y &>> $LOG_FILE
       if [ $? -ne 0 ]; then
           echo "Installing $package installation failed" | tee -a $LOG_FILE
           exit 1
       else
           echo "$package installation Successfully" | tee -a $LOG_FILE
       fi
   fi
done