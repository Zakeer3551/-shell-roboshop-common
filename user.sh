#!/bin/bash

source ./common.sh

SCRIPT_DIR=$PWD
component=user


check_root
nodejs_setup
app_setup
systemd_setup
print_total_time