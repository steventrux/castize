#! /bin/bash
SECS=5
while [[ 0 -ne $SECS ]]; do
    echo "$SECS.."
    sleep 1
    SECS=$[$SECS-1]
done
sudo apt-get update
