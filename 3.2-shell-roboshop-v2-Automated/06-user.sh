#!/bin/bash

app_name="user"
source ./common.sh
CHECK_ROOT_USER

application_setup
nodejs_setup
systemd_setup
application_restart
print_total_time
