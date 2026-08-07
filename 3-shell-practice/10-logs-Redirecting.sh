#!/bin/bash
##Check root user access or not
USERID=$(id -u)
LOG_DIR="/var/log/shell-script"
LOG_FILE="$LOG_DIR/$0.log"
##Check root user access or not
if [ $USERID -ne 0 ]; then
    echo "You must be root user to run this script" | tee -a $LOG_FILE
    exit 1
fi
echo "You are root user, you can run this script" | tee -a $LOG_FILE

#first argument what we are going to install 
#second argument what are the exit codes
VALIDATE() {
    if [ $2 -ne 0 ]; then
        echo "Installing $1 installation failed" | tee -a $LOG_FILE
        exit 1
    else
        echo "$1 installation Successfully" | tee -a $LOG_FILE
    fi
}

##Checking mysql-server is installed or not
dnf list installed mysql &>> $LOG_FILE
if [ $? -eq 0 ]; then
    echo "mysql-server is already installed So Skiiping mysql-server installation" | tee -a $LOG_FILE
else 
    echo "mysql-server is not installed So Installing mysql-server" | tee -a $LOG_FILE
    dnf install mysql -y &>> $LOG_FILE
    VALIDATE mysql $?
fi
## Installing nginx server
dnf list installed nginx &>> $LOG_FILE
if [ $? -eq 0 ]; then
    echo "nginx is already installed So Skiiping nginx installation" | tee -a $LOG_FILE
else 
    echo "nginx is not installed So Installing nginx" | tee -a $LOG_FILE
    dnf install nginx -y &>> $LOG_FILE
    VALIDATE nginx $?
fi