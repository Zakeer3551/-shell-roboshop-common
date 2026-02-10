#!/bin/bash


source ./common.sh

component=mysql

check_root  

dnf install mysql-server -y &>>$LOGS_FILE
VALIDATE $? "Installing mysql-server"

systemctl enable mysqld &>>$LOGS_FILE
systemctl start mysqld  
VALIDATE $? "Enabling and starting mysql"


mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Setup root password"

print_total_time