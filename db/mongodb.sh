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

cp /home/ec2-user/shellscript-roboshop/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copied mongo.repo"

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "Installed mongodb-org"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "Enabled mongod service"

systemctl start mongod &>> $LOGFILE
VALIDATE $? "Started mongod service"

# Update MongoDB configuration to listen on all IP addresses
sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "Updated MongoDB bindIp configuration"

systemctl restart mongod &>>LOGFILE
VALIDATE$? "Restart mongod"
