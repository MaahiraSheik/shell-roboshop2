#!/bin/bash

START_TIME=$(date +%s)
source ./common.sh
app_name=redis
Check_Root

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "disabling default redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "enabling redis"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Edited redis.conf to accept remote connections"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "enabling the redis"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "starting the redis"

Print_Time