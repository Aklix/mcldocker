#!/bin/bash
set -e 

# Start SSH daemon 
/usr/sbin/sshd -D &  # Run in the background

exec "$@"

