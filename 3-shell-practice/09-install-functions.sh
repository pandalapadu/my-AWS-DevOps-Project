#!/bin/bash
USERID=$(id -u)

##Check root user access or not
if [ $USERID -ne 0 ]; then
    echo "You must be root user to run this script"
    exit 1
fi
echo "You are root user, you can run this script"
echo "Installing mysql-server"
dnf install mysqlertry -y 
if [ $? -ne 0 ]; then
    echo "mysql-server installation failed"
    exit 1
else
    echo "mysql-server installation Successfully"
fi