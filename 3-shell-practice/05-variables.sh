#!/bin/bash
# TimeStamp=$(date)
# echo "Current Time is: $TimeStamp"

START_TIME=$(date +%s)
echo "Start Time is: $START_TIME"
sleep 10
END_TIME=$(date +%s)
echo "End Time is: $END_TIME"
DIFF_TIME=$((END_TIME - START_TIME))
echo "Total Time Taken is: $DIFF_TIME seconds"