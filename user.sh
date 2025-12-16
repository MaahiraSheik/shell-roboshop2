#!/bin/bash

START_TIME=$(date +%s)
source ./common.sh
app_name=user
Check_Root
nodejs_setup
app_setup
systemd_setup
Print_Time



