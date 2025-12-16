#!/bin/bash
START_TIME=$(date +%s)
source ./common.sh
Check_Root
app_setup
nodejs_setup
system_setup
systemd_setup
app_name=catalogue


cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "copying mongodb repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "installing mongodb client"

STATUS=$(mongosh --host mongodb.miasha84s.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.miasha84s.site </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "loading data into mongodb"
else
    echo -e "date loaded already.. $Y SKIPPING $N"
fi

Print_Time