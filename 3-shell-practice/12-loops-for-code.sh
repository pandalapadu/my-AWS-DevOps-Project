#!/bin/bash
##Check root user access or not
USERID=$(id -u)
LOG_DIR="/var/log/shell-script"
LOG_FILE="$LOG_DIR/$0.log"

if [ $USERID -ne 0 ]; then
    echo "You must be root user to run this script"
    exit 1
fi
echo "You are root user, you can run this script"

for package in $@
do 
   dnf list installed $package
   if [ $? -eq 0 ]; then
       echo "$package is already installed So Skiiping $package installation"
   else 
       echo "$package is not installed So Installing $package"
       dnf install $package -y
       if [ $? -ne 0 ]; then
           echo "Installing $package installation failed"
           exit 1
       else
           echo "$package installation Successfully"
       fi
   fi
done