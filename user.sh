#!/bin/bash

START_TIME=$(date +%s)
app_name=user
source ./common.sh
Check_Root
nodejs_setup
app_setup
systemd_setup
Print_Time



