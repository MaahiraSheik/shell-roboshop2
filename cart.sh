#!/bin/bash
START_TIME=$(date +%s)
source ./common.sh
app_name=cart
Check_Root
app_setup
nodejs_setup
systemd_setup
Print_Time

