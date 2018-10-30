#!/bin/bash

ROOTDIR=$(pwd)
DIR=$1
cd $DIR
pwd

KEYS=()
ALLNUMBERS=()

index=0;

rm -r "/tmp/studyhymnal/keys/"

for i in `find ./`; do
    echo $i
    KEYLINE=$(grep -n "Key[ ]*|"  $i | cut -d: -f 1)
    # KEYLINE=$(sed -n "$KEYLINE{p;q}" )
    # echo "keyline=>$KEYLINE"
    # SONGNUMBER=$(echo $THIRDLINE | sed -e "s/[^0-9]//g")
    # SONGTITLE=$(echo $THIRDLINE | cut -d' ' -f4-)

    # # remove leading zeros
    # SONGNUMBERSHORT=$(echo $SONGNUMBER | sed 's/^0*//')
    if [ !  -z  $KEYLINE  ]; then
        let "KEYLINE+=2"
        KEYLINE=$(sed -n "$KEYLINE{p;q}" $i)
        KEYLINE=$(echo $KEYLINE| sed -e s/" "/_/g)
        PARTS=(${KEYLINE//|/ })
        KEY=${PARTS[0]}
        KEY=$(echo $KEY| sed -e s/_/" "/g)
        # remove leading and trailing spaces
        KEY=$(echo $KEY | sed 's/^[ \t]*//;s/[ \t]*$//')
        echo $KEY
        THIRDLINE=$(sed -n '3{p;q}' $i)
        SONGNUMBER=$(echo $THIRDLINE | sed -e "s/[^0-9]//g")
        SONGTITLE=$(echo $THIRDLINE | cut -d' ' -f4-)
        SONGNUMBERSHORT=$(echo $SONGNUMBER | sed 's/^0*//')
        mkdir -p "/tmp/studyhymnal/keys/"
        KEY=$(echo $KEY| sed -e s/" "/_/g)
        echo "$SONGNUMBER|$SONGTITLE" >> "/tmp/studyhymnal/keys/$KEY"
    fi 
done


KEYS=()
index=0;
cd "/tmp/studyhymnal/keys/"
for i in `find ./`; do
    KEY=$(echo $i | cut -c3-)
    KEYS[$index]=$KEY
    let "index++"
done

printf '%s\n' "${KEYS[@]}"
readarray -td '' SORTEDKEYS < <(printf '%s\0' "${KEYS[@]}" | sort -z)

tmplocation=$(pwd)
cd $ROOTDIR
cd $DIR
cd ../

line=$(grep -n '## Index of Keys' README.md | cut -d: -f 1)
let "line+=2"

cd "$tmplocation"
for i in "${SORTEDKEYS[@]}"; do
    SONGS=()
    echo "is key: $i"
    index=0
    while read p; do
        LINE=$(echo $p| sed -e s/" "/_/g)
        PARTS=(${LINE//|/ })
        SONGNUMBER=${PARTS[0]}
        SONGTITLE=${PARTS[1]}
        SONGNUMBERSHORT=$(echo $SONGNUMBER | sed 's/^0*//')
        LINE="$SONGNUMBER|$SONGTITLE"
        SONGS[$index]=$LINE
        let "index++"
    done <$i

    echo "sorting songs"
    printf '%s\n' "${SONGS[@]}"
    #SORT SONGS
    readarray -td '' SONGSSORTED < <(printf '%s\0' "${SONGS[@]}" | sort -z)

    tmplocation=$(pwd)
    cd $ROOTDIR
    cd $DIR
    cd ../
    pwd

    for j in "${SONGSSORTED[@]}"; do
        LINE=$j
        PARTS=(${LINE//|/ })
        SONGNUMBER=${PARTS[0]}
        SONGTITLE=${PARTS[1]}
        SONGTITLE=$(echo $SONGTITLE| sed -e s/" "/_/g)
        SONGNUMBERSHORT=$(echo $SONGNUMBER | sed 's/^0*//')
        LINE="$i=>$SONGNUMBERSHORT|$SONGTITLE"
        KEYR=$(echo $i| sed -e s/_/" "/g)
        # echo $LINE
        if [ !  -z  $SONGNUMBERSHORT  ]; then        
            sed -i "$line a $SONGNUMBERSHORT  | $KEYR | [$SONGTITLE](gitsongs/$SONGNUMBER.md)" README.md
            let "line++"
        fi
    done

    cd "$tmplocation"

    # printf '%s\n' "${SONGSSORTED[@]}"

done

