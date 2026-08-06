#!/bin/bash
USERID=$(id -u)

##check the root access or not 
if [ $USERID -ne 0 ]; then
    echo "You need to have root access to run this script."
    exit 1
fi
echo "I am continuing the script as root user"
echo "I am installing mySQL server  on this machine"
dnf install mysql -y
if [ $? -eq 0 ]; then
    echo "mySQL server installed successfully"
else
    echo "mySQL server installation failed"
    exit 1
fi