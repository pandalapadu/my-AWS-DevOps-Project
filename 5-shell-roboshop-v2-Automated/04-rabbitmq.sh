#!/bin/bash
source ./common.sh
CHECK_ROOT_USER

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo 
VALIDATE $? "Adding RabbitMQ repo"

dnf install rabbitmq-server -y &>> $LOGS_FILE
VALIDATE $? "Installing RabbitMQ server"

systemctl enable rabbitmq-server &>> $LOGS_FILE
systemctl start rabbitmq-server &>> $LOGS_FILE
VALIDATE $? "Enabling and starting rabbitmq server"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGS_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGS_FILE
VALIDATE $? "setting up username and password"

print_total_time