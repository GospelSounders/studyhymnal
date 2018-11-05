#!/bin/bash

ROOTDIR=$(pwd)

DIR=$1
cd $DIR
pwd
rm -r gitsongs
cp -r songs gitsongs
cd gitsongs


pwd
# echo $(cp "001.txt" "001.md")
for file in *.txt; do 
	newFile="${file/.txt/.md}"
	mv "$file" "$newFile"
	echo "$file->$newFile"
done
for file in *.md; do sed -i ':a;N;$!ba;s/\n/\n\n/g' $file; done
for file in *.md; do sed -i ':a;N;$!ba;s/Refrain\n/# Refrain\n/g' $file; done
find ./ -type f -exec sed -i "s/\([0-9]\)$/# \0/g"  {} \; #stanza numbers
find ./ -type f -exec sed -i '1 s/^/# /' {} \;  # Song number
find ./ -type f -exec sed -i '$s/$/\n\n[⬅️ Back to index](..\/README.md)/' {} \; #at the end
find ./ -type f -exec sed -i '1 s/^/[⬅️ Back to index](..\/README.md)\n\n/' {} \; #at the begining


cd $ROOTDIR

echo $ROOTDIR
echo $DIR

./createtitleindices.sh "$DIR/gitsongs"
./indexofkeys.sh "$DIR/gitsongs"
./indexoftunes.sh "$DIR/gitsongs"
./indexofauthors.sh "$DIR/gitsongs"
./metricalindex.sh "$DIR/gitsongs"
./indexofhymndates.sh "$DIR/gitsongs"
./indexoforiginallanguages.sh "$DIR/gitsongs"
./indexoftranslationdates.sh "$DIR/gitsongs"
./indexofsources.sh "$DIR/gitsongs"