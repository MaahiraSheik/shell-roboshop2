#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "script started executing at: $(date)" &>>$LOG_FILE

if [ $USERID -ne 0 ]
then
echo -e "$R ERROR: please run with this root access $N" | tee -a $LOG_FILE
exit 1
else
echo "your is running with root access"  | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 -eq 0 ]; then
    echo -e "$2 is... $G Success $N"  | tee -a $LOG_FILE
  else
    echo -e "$2 is... $R Failure $N"  | tee -a $LOG_FILE
    exit 1
  fi
}

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