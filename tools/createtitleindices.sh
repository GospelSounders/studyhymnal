#!/bin/bash

DIR=$1
cd $DIR
pwd
for i in `find ./`; do
#   sed -e "s/[^0-9]//g" $i;
# echo $i
THIRDLINE=$(sed -n '3{p;q}' $i)
SONGNUMBER=$(echo $THIRDLINE | sed -e "s/[^0-9]//g")
# echo $THIRDLINE
# echo $SONGNUMBER
SONGTITLE=$(echo $THIRDLINE | cut -d' ' -f4-)


 if [ !  -z  $SONGNUMBER  ]; then
     echo $SONGNUMBER'->'$SONGTITLE 
    echo $SONGNUMBER'->'$SONGTITLE >> tmp.txt
fi 
# echo "Something->"$i
done

wc -l tmp.txt