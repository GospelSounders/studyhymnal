#!/bin/bash
ROOTDIR=$(pwd)
DIR=$1
cd $DIR
pwd

ALLTITLES=()
ALLNUMBERS=()

index=0;

for i in `find ./`; do
    THIRDLINE=$(sed -n '3{p;q}' $i)
    SONGNUMBER=$(echo $THIRDLINE | sed -e "s/[^0-9]//g")
    SONGTITLE=$(echo $THIRDLINE | cut -d' ' -f4-)

    # remove leading zeros
    SONGNUMBERSHORT=$(echo $SONGNUMBER | sed 's/^0*//')
    if [ !  -z  $SONGNUMBERSHORT  ]; then
        TMP="$SONGNUMBER->$SONGTITLE"
        TMP=$(echo $TMP| sed -e s/" "/_/g)
        # ALLTITLES+=( $TMP )
        ALLTITLES[$index]=$TMP
        let "index++"
        echo $index
        ALLNUMBERS+=( $SONGNUMBERSHORT )
    fi 
done

cd ../

readarray -td '' SORTEDTITLES < <(printf '%s\0' "${ALLTITLES[@]}" | sort -z)
printf '%s\n' "${SORTEDTITLES[@]}"

mkdir -p indices
cp "templates/indexoftitles.template.md" "indices/indexoftitles.md" 

line=$(grep -n '# Index of Titles' indices/indexoftitles.md | cut -d: -f 1)
let "line+=2"

cp templates/README.template.md README.md 

for i in "${SORTEDTITLES[@]}"; do
    arrIN=(${i//->/ })
    SONGNUMBER=${arrIN[0]}
    SONGTITLE=${arrIN[1]}
    SONGTITLE=$(echo $SONGTITLE| sed -e s/_/" "/g)
    SONGNUMBERSHORT=$(echo $SONGNUMBER | sed 's/^0*//')

    #insert into README
    # echo "$SONGNUMBERSHORT=>$SONGTITLE"
    sed -i "$line a $SONGNUMBERSHORT  | [$SONGTITLE](../gitsongs/$SONGNUMBER.md)" indices/indexoftitles.md

    #insert song headers
    sed "4r songheaders/$SONGNUMBER.md" < gitsongs/$SONGNUMBER.md  > tempFile.txt
    mv tempFile.txt gitsongs/$SONGNUMBER.md 
 
    let "line++"
done
