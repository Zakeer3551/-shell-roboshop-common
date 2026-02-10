#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
START_TIME=$(date +%s)

echo "$(date "+%Y-%m-%d %H:%M:%S") | Script started executing at $(date)"  | tee -a $LOGS_FILE

mkdir -p $LOGS_FOLDER

check_root(){
if [ $USER_ID -ne 0 ]; then
    echo "$R Please run the script with Root user $N" | tee -a $LOGS_FILE
    exit 1
fi    
}

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... :: $R FAILED $N" | tee -a $LOGS_FILE
    else 
        echo -e "$2 ... :: $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

nodejs_setup(){
    dnf module disable nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Disabling existing default nodejs version"

    dnf module enable nodejs:20 -y &>>$LOGS_FILE
    VALIDATE $? "Enabling nodejs 20 version"

    dnf install nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Installing nodejs"

    npm install &>>$LOGS_FILE
    VALIDATE $? "Installing dependencies"

}

java_setup(){
    dnf install maven -y &>>$LOGS_FILE
    VALIDATE $? "Installing Maven"

    cd /app

    mvn clean package &>>$LOGS_FILE
    VALIDATE $? "Installing and Building $component"

    mv target/$component-1.0.jar $component.jar 
    VALIDATE $? "Moving and Renaming $component"

}

python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
    VALIDATE $? "Installing Python"

    cd /app 
    pip3 install -r requirements.txt &>>$LOGS_FILE
    VALIDATE $? "Installing dependencies"
}

app_setup(){

    id roboshop &>>$LOGS_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
        VALIDATE $? "Creating system User"
    else
        echo -e "User already exists $Y SKIPPING $N"
    fi

    mkdir -p /app &>>$LOGS_FILE
    VALIDATE $? "Creating app directory"

    curl -o /tmp/$component.zip https://roboshop-artifacts.s3.amazonaws.com/$omponent-v3.zip &>>$LOGS_FILE
    VALIDATE $? "Downloading the application"

    cd /app &>>$LOGS_FILE
    VALIDATE $? "moving to app directory"

    rm -rf /app/* &>>$LOGS_FILE
    VALIDATE $? "Removing existing code"

    unzip /tmp/$component.zip &>>$LOGS_FILE
    VALIDATE $? "unzipping the $component code into app directory"

}

systemd_setup(){
    cp $SCRIPT_DIR/$component.service /etc/systemd/system/$component.service &>>$LOGS_FILE
    VALIDATE $? "Copying the systemctl service"

    systemctl daemon-reload
    systemctl enable $component  &>>$LOGS_FILE
    systemctl start $component 
    VALIDATE $? "Starting and enabling $component"

}

app_restart(){
    systemctl restart $component
    VALIDATE $? "Restarting $component"
}

print_total_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") | Script execute in: $G $TOTAL_TIME seconds $N" | tee -a $LOGS_FILE