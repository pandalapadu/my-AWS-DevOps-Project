#!/bin/bash

##### Special Vars #####
echo "All variables passed to script: $@"
echo "Number of variables passed: $#"
echo "First variable: $1"
echo "Script name: $0"
echo "Current user: $USER"
echo "Current working directory: $PWD"
echo "Home directory: $HOME"
echo "PID of the current script: $$"
sleep 5 &
echo "PID of the background command running just now: $!"
wait $!
echo "Line number: $LINENO"
echo "Script executed in $SECONDS seconds"
echo "Random number: $RANDOM"
echo "Exit code of previous command: $?"