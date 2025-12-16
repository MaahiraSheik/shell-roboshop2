#!/bin/bash

START_TIME=$(date +%s)
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
Check_Root(){
if [ $USERID -ne 0 ]
then
echo -e "$R ERROR: please run with this root access $N" | tee -a $LOG_FILE
exit 1
else
echo "your is running with root access"  | tee -a $LOG_FILE
fi
}

app_setup(){
id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]
then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
VALIDATE $? "Create Sytem User"
else
echo -e "system user roboshop already created...$YSKIPPING..$N"
fi

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "creating App directory"

curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip 
VALIDATE $? "Downloading the $app_name"

rm -rf /app/*
cd /app 
unzip /tmp/$app_name.zip &>>$LOG_FILE
VALIDATE $? "Unzipping the $app_name"

}

nodejs_setup(){
   dnf module disable nodejs -y &>>$LOG_FILE
   VALIDATE $? "Disabling Default nodeje:20"

   dnf module enable nodejs:20 -y &>>$LOG_FILE
   VALIDATE $? "enabling nodejs:20"

   dnf install nodejs -y &>>$LOG_FILE
   VALIDATE $? "Installling Nodejs:20"
   npm install &>>$LOG_FILE
   VALIDATE $? "Installing dependencies"
}

systemd_setup(){
cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
VALIDATE $? "copying $app_name service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "daemon reload"

systemctl enable $app_name  &>>$LOG_FILE
VALIDATE $? "enable $app_name reload"
systemctl start $app_name &>>$LOG_FILE
VALIDATE $? "start cataloguw reload"
}

VALIDATE(){
    if [ $1 -eq 0 ]; then
    echo -e "$2 is... $G Success $N"  | tee -a $LOG_FILE
  else
    echo -e "$2 is... $R Failure $N"  | tee -a $LOG_FILE
    exit 1
  fi
}

Print_Time(){
    END_TIME=$(date +%s)
    TOTALTIME=($END_TIME-$START_TIME)
    echo -e "script executed successfully, $Y tike taken: $TOTALTIME Seconds $N"
}

