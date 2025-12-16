#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

START_TIME=$(date +%s)

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

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "install python3"

id roboshop
if [ $? -ne 0 ]
then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
VALIDATE $? "Create Sytem User"
else
echo -e "system user roboshop already created...$Y SKIPPING..$N"
fi

mkdir -p /app &>>LOG_FILE
VALIDATE $? "creating App directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading the payment"

rm -rf /app/*
cd /app 
unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "Unzipping the payment"

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "install dependencies"

cp payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
VALIDATE $? "copying payment service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "daemon reload"

systemctl enable payment &>>$LOG_FILE
VALIDATE $? "enabling the payment"

systemctl start payment &>>$LOG_FILE
VALIDATE $? "starting the payment"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script execution complted successfully, $Y Time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE

