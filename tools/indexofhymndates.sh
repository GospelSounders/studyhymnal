#!/bin/bash

ROOTDIR=$(pwd)
DIR=$1
cd $DIR
pwd

DATES=()
ALLNUMBERS=()

index=0;

rm -r "/tmp/studyhymnal/dates/"

for i in `find ./`; do
    # echo $i
    DATELINENUMBER=$(grep -n "Hymn Date[ ]*|"  $i | cut -d: -f 1)
    if [ !  -z  $DATELINENUMBER  ]; then
        DATELINE=$(sed -n "$DATELINENUMBER{p;q}" $i)
        # echo $DATELINE
        DATELINE=$(echo $DATELINE| sed -e s/" "/_/g)
        declare -A PARTST
        PARTS=(${DATELINE//|/ })
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

        DATEINDEX=${PARTST[Hymn_Date]}
        # printf '%s\n' "${PARTST[@]}"
        let "DATELINENUMBER+=2"
        DATELINE=$(sed -n "$DATELINENUMBER{p;q}" $i)
        DATELINE=$(echo $DATELINE| sed -e s/" "/_/g)
        declare -A PARTST
        PARTS=(${DATELINE//|/ })
        # printf '%s\n' "${PARTS[@]}"
        DATE=${PARTS[$DATEINDEX]}
        TMP=$(echo $DATE| sed -e s/_/" "/g)
        # trim leading and trailing whitespaces
        TMP=$(echo $TMP | sed 's/^[ \t]*//;s/[ \t]*$//')
        TMP=$(echo $TMP| sed -e s/" "/_/g)
        DATE=$TMP
        echo $DATE

        THIRDLINE=$(sed -n '3{p;q}' $i)
        SONGNUMBER=$(echo $THIRDLINE | sed -e "s/[^0-9]//g")
        SONGTITLE=$(echo $THIRDLINE | cut -d' ' -f4-)
        SONGNUMBERSHORT=$(echo $SONGNUMBER | sed 's/^0*//')
        mkdir -p "/tmp/studyhymnal/dates/"
        echo "$SONGNUMBER|$SONGTITLE" >> "/tmp/studyhymnal/dates/$DATE"
    fi 
done


DATES=()
index=0;
cd "/tmp/studyhymnal/dates/"
for i in `find ./`; do
    DATE=$(echo $i | cut -c3-)
    DATES[$index]=$DATE
    echo $DATE
    let "index++"
done

printf '%s\n' "${DATES[@]}"
readarray -td '' SORTEDDATES < <(printf '%s\0' "${DATES[@]}" | sort -z)

tmplocation=$(pwd)
cd $ROOTDIR
cd $DIR
cd ../

cp "templates/indexofhymndates.template.md" "indices/indexofhymndates.md" 
line=$(grep -n '# Index of Hymn Dates' indices/indexofhymndates.md | cut -d: -f 1)
let "line+=2"

cd "$tmplocation"
for i in "${SORTEDDATES[@]}"; do
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

    HYMNCOUNT=$(wc -l < $i)
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
        DATER=$(echo $i| sed -e s/_/" "/g)
        # echo $LINE
        if [ !  -z  $SONGNUMBERSHORT  ]; then        
            sed -i "$line a $SONGNUMBERSHORT  | $DATER | [$SONGTITLE](../gitsongs/$SONGNUMBER.md)| $HYMNCOUNT" indices/indexofhymndates.md
            let "line++"
        fi
    done

    cd "$tmplocation"

    # printf '%s\n' "${SONGSSORTED[@]}"

done

