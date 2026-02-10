#!/bin/bash

source ./common.sh

component=redis
check_root
systemd_setup

dnf module disable redis -y &>>$LOGS_FILE
VALIDATE $? "Disabling $component"

dnf module enable redis:7 -y &>>$LOGS_FILE
VALIDATE $? "Enabling $component:7"

dnf install redis -y &>>$LOGS_FILE
VALIDATE $? "Installing $component"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf 
VALIDATE $? "Allowing remote connections"


systemctl enable redis &>>$LOGS_FILE
systemctl start redis 
VALIDATE $? "Enabled and started Redis"

print_total_time