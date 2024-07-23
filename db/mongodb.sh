#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo  "$2 FAILURE "
        exit 1
    else
        echo  "$2 SUCCESS"
    fi
}

if [ $USERID -ne 0]
then 
    echo "please run the script with root access"
    exit 1
else
    echo "you are super user"
fi

cp /home/ec2-user/shellscript-roboshop/mongo.repo /etc/yum.repos.d/mongo.repo &>>LOGFILE
validate $? "copied mongo.repo"

dnf install mongodb-org -y 
validate $? "install mongo org"

systemctl enable mongod
validate $? "enable db"

systemctl start mongod
validate $? "start mongod"




