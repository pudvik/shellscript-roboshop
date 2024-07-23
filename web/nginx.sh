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
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

dnf install nginx -y &>>LOGFILE
VALIDATE $? "Install Nginx"

systemctl enable nginx &>>LOGFILE
VALIDATE $? "Enable Nginx"

systemctl start nginx &>>LOGFILE
VALIDATE $? "Start Nginx"

rm -rf /usr/share/nginx/html/* &>>LOGFILE
VALIDATE $? "Remove default html directory"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>LOGFILE
VALIDATE $? " Download nginx code"

cd /usr/share/nginx/html &>>LOGFILE
VALIDATE $? "Move to html directory"

unzip /tmp/web.zip &>>LOGFILE
VALIDATE $? "Extracting web code"

cp /home/ec2-user/shellscript-roboshop/roboshop.conf /etc/nginx/default.d/roboshop.conf &>>LOGFILE
VALIDATE $? "Copied conf file"

systemctl restart nginx &>>LOGFILE
VALIDATE $? "Restart Nginx"


