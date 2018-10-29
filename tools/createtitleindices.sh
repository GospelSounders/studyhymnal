#!/bin/bash

DIR=$1
cd $DIR
pwd

ALLTITLES=()
ALLNUMBERS=()

index=0;

for i in `find ./`; do
#   sed -e "s/[^0-9]//g" $i;
# echo $i
THIRDLINE=$(sed -n '3{p;q}' $i)
SONGNUMBER=$(echo $THIRDLINE | sed -e "s/[^0-9]//g")
# echo $THIRDLINE
# echo $SONGNUMBER
SONGTITLE=$(echo $THIRDLINE | cut -d' ' -f4-)

# remove leading zeros
SONGNUMBERSHORT=$(echo $SONGNUMBER | sed 's/^0*//')
if [ !  -z  $SONGNUMBERSHORT  ]; then
    # echo $SONGNUMBERSHORT'->'$SONGTITLE 
    TMP="$SONGNUMBER->$SONGTITLE"
    TMP=$(echo $TMP| sed -e s/" "/_/g)
    ALLTITLES+=( $TMP )
    ALLTITLES[$index]=$TMP
    # index=$index+1
    let "index++"
    echo $index
    ALLNUMBERS+=( $SONGNUMBERSHORT )
    # echo $SONGNUMBER'->'$SONGTITLE >> tmp.txt
fi 
done


# printf '%s\n' "${ALLTITLES[@]}"

# arr2=($(echo ${ALLTITLES[*]}| tr "....||" "\n" | sort -z))

cd ../
cat README.md
# printf '%s\n' "${arr2[@]}"

# # echo ${arr2[*]}

# echo "...................................."
# echo ${ALLTITLES[0]}
# echo ${ALLTITLES[1]}
# echo ${ALLTITLES[2]}
# echo ${ALLTITLES[3]}

# echo ${arr2[0]}
# echo ${arr2[1]}
# echo ${arr2[2]}
# echo ${arr2[3]}

# printf '%s\n' "${ALLTITLES[@]}" | sort -n
echo "...................................."

readarray -td '' SORTEDTITLES < <(printf '%s\0' "${ALLTITLES[@]}" | sort -z)
printf '%s\n' "${SORTEDTITLES[@]}"

line=$(grep -n '## Index of Titles' README.md | cut -d: -f 1)
let "line+=2"

cp README.template.md README.md 
# echo $line
for i in "${SORTEDTITLES[@]}"; do
    arrIN=(${i//->/ })
    SONGNUMBER=${arrIN[0]}
    SONGTITLE=${arrIN[1]}
    SONGTITLE=$(echo $SONGTITLE| sed -e s/_/" "/g)
    SONGNUMBERSHORT=$(echo $SONGNUMBER | sed 's/^0*//')

    #insert into README
    # echo "$SONGNUMBERSHORT=>$SONGTITLE"
    sed -i "$line a $SONGNUMBERSHORT  | [$SONGTITLE](gitsongs/$SONGNUMBER.md)" README.md

    
    # HEADER=$(cat songheaders/$SONGNUMBER.md 2>/dev/null )

    # headerline=5
    # if [ !  -z  "$HEADER"  ]; then
    # # if [ !  -z  $header ]; then
    #    sed -i "$headerline a \$header" gitsongs/$SONGNUMBER.md 

    #    sed "5r songheaders/$SONGNUMBER.md" < gitsongs/$SONGNUMBER.md  > tempFile.txt
    # mv tempFile.txt gitsongs/$SONGNUMBER.md 
    # fi 

    sed "5r songheaders/$SONGNUMBER.md" < gitsongs/$SONGNUMBER.md  > tempFile.txt
    mv tempFile.txt gitsongs/$SONGNUMBER.md 
    
    
    # pwd
    # echo $header
    let "line++"
done
