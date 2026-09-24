#!/bin/bash

THRESHOLD=80 # Alerta si el uso del disco es más del 80%
USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

if [ "$USAGE" -ge "$THRESHOLD" ]; then
    echo "Disk usage is $USAGE%. Please Check"
else
    echo "Disk usage is $USAGE%, disk space good"
fi
