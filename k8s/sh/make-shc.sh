#!/bin/bash 

BASE_DIR=`cd $(dirname $0)/./; pwd`

# echo "BASE_DIR $BASE_DIR"

if [ ! -d $BASE_DIR/../bin ]; then 
  mkdir $BASE_DIR/../bin
fi

cd $BASE_DIR 

IFS=$(echo -en "\n\b")
for fileName in `ls k8s-*.sh`
do
  name=${fileName%.sh}
  shc -f $fileName -o $BASE_DIR/../bin/$name
done

rm -f *.sh.x
rm -f *.sh.x.c
