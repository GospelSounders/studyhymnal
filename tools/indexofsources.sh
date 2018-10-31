#!/bin/bash

ROOTDIR=$(pwd)
DIR=$1
cd $DIR
pwd

SOURCES=()
ALLNUMBERS=()

index=0;

rm -r "/tmp/studyhymnal/sources/"

for i in `find ./`; do
    # echo $i
    SOURCELINENUMBER=$(grep -n "Composer/Source[ ]*"  $i | cut -d: -f 1)
    if [ !  -z  $SOURCELINENUMBER  ]; then
        SOURCELINE=$(sed -n "$SOURCELINENUMBER{p;q}" $i)
        # echo $SOURCELINE
        SOURCELINE=$(echo $SOURCELINE| sed -e s/" "/_/g)
        declare -A PARTST
        PARTS=(${SOURCELINE//|/ })
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

        SOURCEINDEX=${PARTST[Composer/Source]}
        # printf '%s\n' "${PARTST[@]}"
        let "SOURCELINENUMBER+=2"
        SOURCELINE=$(sed -n "$SOURCELINENUMBER{p;q}" $i)
        SOURCELINE=$(echo $SOURCELINE| sed -e s/" "/_/g)
        declare -A PARTST
        PARTS=(${SOURCELINE//|/ })
        # printf '%s\n' "${PARTS[@]}"
        SOURCE=${PARTS[$SOURCEINDEX]}
        TMP=$(echo $SOURCE| sed -e s/_/" "/g)
        # trim leading and trailing whitespaces
        TMP=$(echo $TMP | sed 's/^[ \t]*//;s/[ \t]*$//')
        TMP=$(echo $TMP| sed -e s/" "/_/g)
        SOURCE=$TMP
        echo $SOURCE

        THIRDLINE=$(sed -n '3{p;q}' $i)
        SONGNUMBER=$(echo $THIRDLINE | sed -e "s/[^0-9]//g")
        SONGTITLE=$(echo $THIRDLINE | cut -d' ' -f4-)
        SONGNUMBERSHORT=$(echo $SONGNUMBER | sed 's/^0*//')
        mkdir -p "/tmp/studyhymnal/sources/"
        echo "$SONGNUMBER|$SONGTITLE" >> "/tmp/studyhymnal/sources/$SOURCE"
    fi 
done


SOURCES=()
index=0;
cd "/tmp/studyhymnal/sources/"
for i in `find ./`; do
    SOURCE=$(echo $i | cut -c3-)
    SOURCES[$index]=$SOURCE
    let "index++"
done

printf '%s\n' "${SOURCES[@]}"
readarray -td '' SORTEDSOURCES < <(printf '%s\0' "${SOURCES[@]}" | sort -z)

tmplocation=$(pwd)
cd $ROOTDIR
cd $DIR
cd ../

cp "templates/indexofsources.template.md" "indices/indexofsources.md" 
line=$(grep -n '# Index of Sources' indices/indexofsources.md | cut -d: -f 1)let "line+=2"let "line+=2"let "line+=2"

cd "$tmplocation"
for i in "${SORTEDSOURCES[@]}"; do
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
        SOURCER=$(echo $i| sed -e s/_/" "/g)
        # echo $LINE
        if [ !  -z  $SONGNUMBERSHORT  ]; then        
            sed -i "$line a $SONGNUMBERSHORT  | $SOURCER | [$SONGTITLE](gitsongs/$SONGNUMBER.md)" indices/indexofsources.md
            let "line++"
        fi
    done

    cd "$tmplocation"

    # printf '%s\n' "${SONGSSORTED[@]}"

done

