#!/bin/bash

source ./common.sh
Check_Root
cp mongo.repo /etc/yum.repos.d/mongodb.repo &>>$LOG_FILE
VALIDATE $? "copying mongodb repo"

dnf install -y mongodb-org &>>$LOG_FILE
VALIDATE $? "install mongodb"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "enable Mongodb service"
systemctl start mongod &>>$LOG_FILE
VALIDATE $? "starting Mongodb service"

sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing mongodb conf file for remote connections"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "restart mongodb"

Print_Time