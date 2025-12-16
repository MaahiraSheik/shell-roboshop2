#!/bin/bash
START_TIME=$(date +%s)
source ./common.sh
Check_Root
app_name=frontend

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling Default Nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabling Nginx:1.24"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx  &>>$LOG_FILE
systemctl start nginx 
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Removing default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading frontend"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzipping frontend"

rm -rf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "Remove default nginx conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying nginx.conf"

systemctl restart nginx 
VALIDATE $? "Restarting nginx"

Print_Time

# dnf module disable nginx -y &>>LOG_FILE
# VALIDATE $? "disabling nginx"

# dnf module enable nginx:1.24 -y &>>LOG_FILE
# VALIDATE $? "enabling nginx"

# dnf install nginx -y &>>LOG_FILE
# VALIDATE $? "installing nginx"

# systemctl enable nginx &>>LOG_FILE
# VALIDATE $? "enable nginx"

# systemctl start nginx &>>LOG_FILE
# VALIDATE $? "start nginx"

# rm -rf /usr/share/nginx/html/* &>>LOG_FILE
# VALIDATE $? "removing default content"

# curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
# VALIDATE $? "Download the frontend"

# cd /usr/share/nginx/html 
# unzip /tmp/frontend.zip &>>LOG_FILE
# VALIDATE $? "Unzipping the frontend"

# cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>LOG_FILE
# VALIDATE $? "copying nginx configutration"

# systemctl restart nginx &>>LOG_FILE
# VALIDATE $? "restarting the nginx"