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

dnf install redis -y &>> $LOGFILE
VALIDATE $? "Install redis"

# Update MongoDB configuration to listen on all IP addresses
sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/redis/redis.conf &>> $LOGFILE
VALIDATE $? "Updated MongoDB bindIp configuration"

systemctl enable redis &>> $LOGFILE
VALIDATE $? "Enable redis"

systemctl start redis &>> $LOGFILE
VALIDATE $? "Start redis"