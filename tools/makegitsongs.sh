#!/bin/bash

ROOTDIR=$(pwd)

DIR=$1
cd $DIR
pwd
rm -r gitsongs
cp -r songs gitsongs
cd gitsongs

for file in *.txt; do mv "$file" "${file/.txt/.md}"; done
for file in *.md; do sed -i ':a;N;$!ba;s/\n/\n\n/g' $file; done
for file in *.md; do sed -i ':a;N;$!ba;s/Refrain\n/# Refrain\n/g' $file; done
find ./ -type f -exec sed -i "s/\([0-9]\)$/# \0/g"  {} \; #stanza numbers
find ./ -type f -exec sed -i '1 s/^/# /' {} \;  # Song number
find ./ -type f -exec sed -i '$s/$/\n\n[⬅️ Back to index](..\/README.md)/' {} \; #at the end
find ./ -type f -exec sed -i '1 s/^/[⬅️ Back to index](..\/README.md)\n\n/' {} \; #at the begining




cd $ROOTDIR

./createtitleindices.sh "$DIR/gitsongs"
