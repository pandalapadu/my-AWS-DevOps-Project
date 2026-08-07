#!/bin/bash
USERID=$(id -u)

##Check root user access or not
if [ $USERID -ne 0 ]; then
    echo "You must be root user to run this script"
    exit 1
fi
echo "You are root user, you can run this script"
##Checking mysql-server is installed or not
dnf list installed mysql
if [ $? -eq 0 ]; then
    echo "mysql-server is already installed"
    exit 0
fi

echo "Installing mysql-server"
dnf install mysql -y 
if [ $? -ne 0 ]; then
    echo "mysql-server installation failed"
    exit 1
else
    echo "mysql-server installation Successfully"
fi