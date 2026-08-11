#!/bin/bash
app_name="payment"
source ./common.sh
CHECK_ROOT_USER
application_setup
python_setup
systemd_setup
application_restart
print_total_time