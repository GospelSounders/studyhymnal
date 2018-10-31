#!/bin/bash

ROOTDIR=$(pwd)
DIR=$1
cd $DIR
pwd

AUTHORS=()
ALLNUMBERS=()

index=0;

rm -r "/tmp/studyhymnal/authors/"

for i in `find ./`; do
    # echo $i
    AUTHORLINENUMBER=$(grep -n "Author[ ]*|"  $i | cut -d: -f 1)
    if [ !  -z  $AUTHORLINENUMBER  ]; then
        AUTHORLINE=$(sed -n "$AUTHORLINENUMBER{p;q}" $i)
        # echo $AUTHORLINE
        AUTHORLINE=$(echo $AUTHORLINE| sed -e s/" "/_/g)
        declare -A PARTST
        PARTS=(${AUTHORLINE//|/ })
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

        AUTHORINDEX=${PARTST[Author]}
        # printf '%s\n' "${PARTST[@]}"
        let "AUTHORLINENUMBER+=2"
        AUTHORLINE=$(sed -n "$AUTHORLINENUMBER{p;q}" $i)
        AUTHORLINE=$(echo $AUTHORLINE| sed -e s/" "/_/g)
        declare -A PARTST
        PARTS=(${AUTHORLINE//|/ })
        # printf '%s\n' "${PARTS[@]}"
        AUTHOR=${PARTS[$AUTHORINDEX]}
        TMP=$(echo $AUTHOR| sed -e s/_/" "/g)
        # trim leading and trailing whitespaces
        TMP=$(echo $TMP | sed 's/^[ \t]*//;s/[ \t]*$//')
        TMP=$(echo $TMP| sed -e s/" "/_/g)
        AUTHOR=$TMP
        echo $AUTHOR

        THIRDLINE=$(sed -n '3{p;q}' $i)
        SONGNUMBER=$(echo $THIRDLINE | sed -e "s/[^0-9]//g")
        SONGTITLE=$(echo $THIRDLINE | cut -d' ' -f4-)
        SONGNUMBERSHORT=$(echo $SONGNUMBER | sed 's/^0*//')
        mkdir -p "/tmp/studyhymnal/authors/"
        echo "$SONGNUMBER|$SONGTITLE" >> "/tmp/studyhymnal/authors/$AUTHOR"
    fi 
done


AUTHORS=()
index=0;
cd "/tmp/studyhymnal/authors/"
for i in `find ./`; do
    AUTHOR=$(echo $i | cut -c3-)
    AUTHORS[$index]=$AUTHOR
    echo $AUTHOR
    let "index++"
done

printf '%s\n' "${AUTHORS[@]}"
readarray -td '' SORTEDAUTHORS < <(printf '%s\0' "${AUTHORS[@]}" | sort -z)

tmplocation=$(pwd)
cd $ROOTDIR
cd $DIR
cd ../

cp "templates/indexofauthors.template.md" "indices/indexofauthors.md" 
line=$(grep -n '# Index of Authors' indices/indexofauthors.md | cut -d: -f 1)
let "line+=2"

cd "$tmplocation"
for i in "${SORTEDAUTHORS[@]}"; do
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
        AUTHORR=$(echo $i| sed -e s/_/" "/g)
        # echo $LINE
        if [ !  -z  $SONGNUMBERSHORT  ]; then        
            sed -i "$line a $SONGNUMBERSHORT  | $AUTHORR | [$SONGTITLE](gitsongs/$SONGNUMBER.md)" indices/indexofauthors.md
            let "line++"
        fi
    done

    cd "$tmplocation"

    # printf '%s\n' "${SONGSSORTED[@]}"

done

