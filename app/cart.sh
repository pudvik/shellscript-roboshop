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
VALIDATE $? "Disable nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enable nodejs"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Install nodejs"

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

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>>$LOGFILE
VALIDATE $? "Download cart code"

cd /app &>>$LOGFILE
VALIDATE $? "Moving app directory"

unzip /tmp/cart.zip &>>$LOGFILE
VALIDATE $? "Unzip code"

npm install &>>$LOGFILE
VALIDATE $? "Install dependencies"

#check your repo and path
cp /home/ec2-user/shellscript-roboshop/cart.service /etc/systemd/system/cart.service &>>$LOGFILE
VALIDATE $? "Copied cart service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reload daemon"

systemctl enable user &>>$LOGFILE
VALIDATE $? "Enable user"

systemctl start user &>>$LOGFILE
VALIDATE $? "Start user"


