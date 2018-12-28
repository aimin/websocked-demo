#!/bin/bash
read MSG

for ((COUNT = 1; COUNT <= 1000000; COUNT++)); do
  echo $COUNT
  echo $MSG
  sleep 1
done
