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

dnf install maven -y &>>$LOGFILE
VALIDATE $? "Install maven"

id roboshop &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "Creating roboshop user"
else
    echo -e "Roboshop user already created...$Y SKIPPING $N"
fi

mkdir /app &>>$LOGFILE
VALIDATE $? "Creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>$LOGFILE
VALIDATE $? "Downlaod shipping code"

cd /app &>>$LOGFILE
VALIDATE $? "Moving app directory"

unzip /tmp/shipping.zip &>>$LOGFILE
VALIDATE $? "Unzip code"

mvn clean package &>>LOGFILE
VALIDATE $? "Clean package"

mv target/shipping-1.0.jar shipping.jar &>>$LOGFILE
VALIDATE $? "Move shipping jar"

cp /home/ec2-user/shellscript-roboshop/shipping.service /etc/systemd/system/shipping.service &>>$LOGFILE
VALIDATE $? "Copied shipping service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon load"

systemctl enable shipping &>>$LOGFILE
VALIDATE $? "Enable shipping"

systemctl start shipping &>>$LOGFILE
VALIDATE $? "Start shipping"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Install mysql server"

mysql -h mysql.daws78s.site -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>$LOGFILE
VALIDATE $? "Loading schema"

systemctl restart shipping &>>$LOGFILE
VALIDATE $? "Restart shipping"

