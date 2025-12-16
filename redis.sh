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

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script execution complted successfully, $Y Time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE