#!/bin/bash

source ./common.sh

cp -p ./mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
VALIDATE $? "Copying mongo repo"

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "Installing mongodb server"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOGS_FILE
VALIDATE $? "Allowing remote connections"

systemctl enable mongod 
systemctl start mongod &>>$LOGS_FILE
VALIDATE $? "Enabling and starting mongod"

print_total_time