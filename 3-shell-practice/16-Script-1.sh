#!/bin/bash
COUNTRY="india"

echo "Hello, $COUNTRY!"
echo "PID of this script-1 is $$"

#sh 17-Script-2.sh #this is not calling environment variable of first script
source ./17-Script-2.sh #this is calling environment variable of first script because source command is used to call the second script and it will run in the same shell as the first script. So, the environment variable COUNTRY will be available in the second script.