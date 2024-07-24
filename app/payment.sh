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

dnf install python36 gcc python3-devel -y &>>$LOGFILE
VALIDATE $? "Install python"

id roboshop &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "Creating roboshop user"
else
    echo -e "Roboshop user already created...$Y SKIPPING $N"
fi

mkdir /app &>>$LOGFILE
VALIDATE $? "App directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$LOGFILE
VALIDATE $? "Downalod code"

cd /app &>>$LOGFILE
VALIDATE $? "Moving app directory"

unzip /tmp/payment.zip &>>$LOGFILE
VALIDATE $? "Unzip code"

pip3.6 install -r requirements.txt &>>$LOGFILE
VALIDATE $? "Install requirements"

cp /home/ec2-user/shellscript-roboshop/payment.service /etc/systemd/system/payment.service &>>$LOGFILE
VALIDATE $? "Copied payment service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reload daemon"

systemctl enable payment &>>$LOGFILE
VALIDATE $? "Enable payment"

systemctl start payment &>>$LOGFILE
VALIDATE $? "Start payment"
