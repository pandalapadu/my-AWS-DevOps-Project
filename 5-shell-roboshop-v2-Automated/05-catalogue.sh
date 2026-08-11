#!/bin/bash
app_name="catalogue"
source ./common.sh
check_root_user

application_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Added Mongo repo" 

dnf install mongodb-mongosh -y &>>$LOGS_FILE
VALIDATE $? "Installed MongoDB client"

INDEX=$(mongosh --host mongodb.azdevopsvenkat.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -lt 0 ]; then
    mongosh --host mongodb.azdevopsvenkat.site </app/db/master-data.js &>>$LOGS_FILE
    VALIDATE $? "Load Products"
else
    echo -e "Products already loaded ... $Y SKIPPING $N"
fi

application_restart
print_total_time