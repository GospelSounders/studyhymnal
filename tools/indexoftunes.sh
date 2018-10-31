#!/bin/bash

ROOTDIR=$(pwd)
DIR=$1
cd $DIR
pwd

TUNES=()
ALLNUMBERS=()

index=0;

rm -r "/tmp/studyhymnal/tunes/"

for i in `find ./`; do
    # echo $i
    TUNELINENUMBER=$(grep -n "Tune[ ]*|"  $i | cut -d: -f 1)
    if [ !  -z  $TUNELINENUMBER  ]; then
        TUNELINE=$(sed -n "$TUNELINENUMBER{p;q}" $i)
        # echo $TUNELINE
        TUNELINE=$(echo $TUNELINE| sed -e s/" "/_/g)
        declare -A PARTST
        PARTS=(${TUNELINE//|/ })
        # printf '%s\n' "${PARTS[@]}"

        # associative array
        indexinner=0
        for j in "${PARTS[@]}"; do
            TMP=$(echo $j| sed -e s/_/" "/g)
            # trim leading and trailing whitespaces
            TMP=$(echo $TMP | sed 's/^[ \t]*//;s/[ \t]*$//')
            TMP=$(echo $TMP| sed -e s/" "/_/g)
            PARTST[$TMP]=$indexinner
            let "indexinner++"
        done

        TUNEINDEX=${PARTST[Tune]}
        # printf '%s\n' "${PARTST[@]}"
        let "TUNELINENUMBER+=2"
        TUNELINE=$(sed -n "$TUNELINENUMBER{p;q}" $i)
        TUNELINE=$(echo $TUNELINE| sed -e s/" "/_/g)
        declare -A PARTST
        PARTS=(${TUNELINE//|/ })
        # printf '%s\n' "${PARTS[@]}"
        TUNE=${PARTS[$TUNEINDEX]}
        TMP=$(echo $TUNE| sed -e s/_/" "/g)
        # trim leading and trailing whitespaces
        TMP=$(echo $TMP | sed 's/^[ \t]*//;s/[ \t]*$//')
        TMP=$(echo $TMP| sed -e s/" "/_/g)
        TUNE=$TMP
        echo $TUNE

        THIRDLINE=$(sed -n '3{p;q}' $i)
        SONGNUMBER=$(echo $THIRDLINE | sed -e "s/[^0-9]//g")
        SONGTITLE=$(echo $THIRDLINE | cut -d' ' -f4-)
        SONGNUMBERSHORT=$(echo $SONGNUMBER | sed 's/^0*//')
        mkdir -p "/tmp/studyhymnal/tunes/"
        echo "$SONGNUMBER|$SONGTITLE" >> "/tmp/studyhymnal/tunes/$TUNE"
    fi 
done


TUNES=()
index=0;
cd "/tmp/studyhymnal/tunes/"
for i in `find ./`; do
    TUNE=$(echo $i | cut -c3-)
    TUNES[$index]=$TUNE
    let "index++"
done

printf '%s\n' "${TUNES[@]}"
readarray -td '' SORTEDTUNES < <(printf '%s\0' "${TUNES[@]}" | sort -z)

tmplocation=$(pwd)
cd $ROOTDIR
cd $DIR
cd ../

cp "templates/indexoftunes.template.md" "indices/indexoftunes.md" 
line=$(grep -n '# Index of Tunes' indices/indexoftunes.md | cut -d: -f 1)
let "line+=2"

cd "$tmplocation"
for i in "${SORTEDTUNES[@]}"; do
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
        SONGTITLE=$(echo $SONGTITLE| sed -e s/_/" "/g)
        SONGNUMBERSHORT=$(echo $SONGNUMBER | sed 's/^0*//')
        LINE="$i=>$SONGNUMBERSHORT|$SONGTITLE"
        TUNER=$(echo $i| sed -e s/_/" "/g)
        # echo $LINE
        if [ !  -z  $SONGNUMBERSHORT  ]; then        
            sed -i "$line a $SONGNUMBERSHORT  | $TUNER | [$SONGTITLE](gitsongs/$SONGNUMBER.md)" indices/indexoftunes.md
            let "line++"
        fi
    done

    cd "$tmplocation"

    # printf '%s\n' "${SONGSSORTED[@]}"

done

