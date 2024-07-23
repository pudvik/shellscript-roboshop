#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo "$2 FAILURE"
        exit 1
    else
        echo "$2 SUCCESS"
    fi
}

if [ $USERID -ne 0 ]
then    
    echo "please run with super user"
else
    echo "you are a super user"
fi


dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling nodejs:20 version"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

id roboshop &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "Creating roboshop user"
else
    echo -e "Roboshop user already created...$Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating app directory"

curl -o curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOGFILE
VALIDATE $? "Downloading backend code"

cd /app
VALIDATE $? "Changing to /app directory"

rm -rf /app/*
VALIDATE $? "Cleaning up /app directory"

unzip -d /tmp/catalogue.zip &>>$LOGFILE
VALIDATE $? "Extracted catalogue code"

npm install &>>$LOGFILE
VALIDATE $? "Installing nodejs dependencies"

#check your repo and path
cp /home/ec2-user/shellscript-roboshop/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon Reload"

systemctl start catalogue &>>$LOGFILE
VALIDATE $? "Starting catalogue"

systemctl enable catalogue &>>$LOGFILE
VALIDATE $? "Enabling catalogue"

cp /home/ec2-user/shellscript-roboshop/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copied mongo.repo"

dnf install -y mongodb-mongosh &>>LOGFILE
VALIDATE $? " Installin mongodb client"

mongosh --host mongodb.daws78s.site </app/schema/catalogue.js
VALIDATE $? "Schema loading"

systemctl restart catalogue &>>$LOGFILE
VALIDATE $? "Restarting catalogue"






