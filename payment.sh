#!/bin/bash

source ./common.sh
component=payment

check_root
app_setup
python_setup
systemd_setup
print_total_time