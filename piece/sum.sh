#!/bin/bash

sum=0
if [ $# -gt 0 ]; then
  for i in $@;
  do
    sum=$(echo "$sum + $i"|bc)
  done; 
fi;

while read line
do

  sum=$(echo "$sum + $line"|bc)
done<&0;

echo $sum