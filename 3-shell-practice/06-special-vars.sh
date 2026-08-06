#!/bin/bash

##### Special Vars #####
echo "Script Name: $0"
echo "All command line variables: $@"
echo "Total number of command line variables: $#"
echo "First command line variable: $1"
echo "Current User: $USER"
echo "Current Working Directory: $PWD"
echo "Home Directory: $HOME"
echo "Process ID of the current shell: $$"
echo "Current Line Number: $LINENO"
echo "Seconds since shell invocation: $SECONDS"
echo "Random Number: $RANDOM"
echo "Exit status of last command: $?"
