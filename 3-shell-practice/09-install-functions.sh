#!/bin/bash
USERID=$(id -u)

##check the root access or not 
if [ $USERID -ne 0 ]; then
    echo "You need to have root access to run this script."
fi

echo "I am continuing the script as root user"