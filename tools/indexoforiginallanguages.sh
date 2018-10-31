#!/bin/bash

ROOTDIR=$(pwd)
DIR=$1
cd $DIR
pwd

LANGUAGES=()
ALLNUMBERS=()

index=0;

rm -r "/tmp/studyhymnal/languages/"

for i in `find ./`; do
    # echo $i
    LANGUAGELINENUMBER=$(grep -n "Original Language[ ]*|"  $i | cut -d: -f 1)
    if [ !  -z  $LANGUAGELINENUMBER  ]; then
        LANGUAGELINE=$(sed -n "$LANGUAGELINENUMBER{p;q}" $i)
        # echo $LANGUAGELINE
        LANGUAGELINE=$(echo $LANGUAGELINE| sed -e s/" "/_/g)
        declare -A PARTST
        PARTS=(${LANGUAGELINE//|/ })
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

        LANGUAGEINDEX=${PARTST[Original_Language]}
        # printf '%s\n' "${PARTST[@]}"
        let "LANGUAGELINENUMBER+=2"
        LANGUAGELINE=$(sed -n "$LANGUAGELINENUMBER{p;q}" $i)
        LANGUAGELINE=$(echo $LANGUAGELINE| sed -e s/" "/_/g)
        declare -A PARTST
        PARTS=(${LANGUAGELINE//|/ })
        # printf '%s\n' "${PARTS[@]}"
        LANGUAGE=${PARTS[$LANGUAGEINDEX]}
        TMP=$(echo $LANGUAGE| sed -e s/_/" "/g)
        # trim leading and trailing whitespaces
        TMP=$(echo $TMP | sed 's/^[ \t]*//;s/[ \t]*$//')
        TMP=$(echo $TMP| sed -e s/" "/_/g)
        LANGUAGE=$TMP
        echo $LANGUAGE

        THIRDLINE=$(sed -n '3{p;q}' $i)
        SONGNUMBER=$(echo $THIRDLINE | sed -e "s/[^0-9]//g")
        SONGTITLE=$(echo $THIRDLINE | cut -d' ' -f4-)
        SONGNUMBERSHORT=$(echo $SONGNUMBER | sed 's/^0*//')
        mkdir -p "/tmp/studyhymnal/languages/"
        echo "$SONGNUMBER|$SONGTITLE" >> "/tmp/studyhymnal/languages/$LANGUAGE"
    fi 
done


LANGUAGES=()
index=0;
cd "/tmp/studyhymnal/languages/"
for i in `find ./`; do
    LANGUAGE=$(echo $i | cut -c3-)
    LANGUAGES[$index]=$LANGUAGE
    echo $LANGUAGE
    let "index++"
done

printf '%s\n' "${LANGUAGES[@]}"
readarray -td '' SORTEDLANGUAGES < <(printf '%s\0' "${LANGUAGES[@]}" | sort -z)

tmplocation=$(pwd)
cd $ROOTDIR
cd $DIR
cd ../

cp "templates/indexoforiginallanguages.template.md" "indices/indexoforiginallanguages.md" 
line=$(grep -n '# Index of Original Languages' indices/indexoforiginallanguages.md | cut -d: -f 1)let "line+=2"let "line+=2"

cd "$tmplocation"
for i in "${SORTEDLANGUAGES[@]}"; do
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
        LANGUAGER=$(echo $i| sed -e s/_/" "/g)
        # echo $LINE
        if [ !  -z  $SONGNUMBERSHORT  ]; then        
            sed -i "$line a $SONGNUMBERSHORT  | $LANGUAGER | [$SONGTITLE](gitsongs/$SONGNUMBER.md)" indices/indexoforiginallanguages.md
            let "line++"
        fi
    done

    cd "$tmplocation"

    # printf '%s\n' "${SONGSSORTED[@]}"

done

