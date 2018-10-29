#!/bin/bash

DIR=$1
cd $DIR
pwd
rm -r gitsongs
cp -r songs gitsongs
cd gitsongs

for file in *.txt; do mv "$file" "${file/.txt/.md}"; done
find ./ -type f -exec sed -i "s/\([0-9]\)$/# \0/g"  {} \; #stanza numbers
find ./ -type f -exec sed -i '1 s/^/# /' {} \;  # Song number
find ./ -type f -exec sed -i '$s/$/\n\n[⬅️ Back to index](..\/README.md)/' {} \; #at the end
find ./ -type f -exec sed -i '1 s/^/[⬅️ Back to index](..\/README.md)\n\n/' {} \; #at the begining
