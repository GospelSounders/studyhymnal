#!/bin/bash

ROOTDIR=$(pwd)
DIR=$1
cd $DIR
pwd

METRICS=()
ALLNUMBERS=()

index=0;

rm -r "/tmp/studyhymnal/metrics/"

for i in `find ./`; do
    # echo $i
    METRICLINENUMBER=$(grep -n "Metrical Pattern[ ]*|"  $i | cut -d: -f 1)
    if [ !  -z  $METRICLINENUMBER  ]; then
        METRICLINE=$(sed -n "$METRICLINENUMBER{p;q}" $i)
        # echo $METRICLINE
        METRICLINE=$(echo $METRICLINE| sed -e s/" "/_/g)
        declare -A PARTST
        PARTS=(${METRICLINE//|/ })
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

        METRICINDEX=${PARTST[Metrical_Pattern]}
        # printf '%s\n' "${PARTST[@]}"
        let "METRICLINENUMBER+=2"
        METRICLINE=$(sed -n "$METRICLINENUMBER{p;q}" $i)
        METRICLINE=$(echo $METRICLINE| sed -e s/" "/_/g)
        declare -A PARTST
        PARTS=(${METRICLINE//|/ })
        # printf '%s\n' "${PARTS[@]}"
        METRIC=${PARTS[$METRICINDEX]}
        TMP=$(echo $METRIC| sed -e s/_/" "/g)
        # trim leading and trailing whitespaces
        TMP=$(echo $TMP | sed 's/^[ \t]*//;s/[ \t]*$//')
        TMP=$(echo $TMP| sed -e s/" "/_/g)
        METRIC=$TMP
        echo $METRIC

        THIRDLINE=$(sed -n '3{p;q}' $i)
        SONGNUMBER=$(echo $THIRDLINE | sed -e "s/[^0-9]//g")
        SONGTITLE=$(echo $THIRDLINE | cut -d' ' -f4-)
        SONGNUMBERSHORT=$(echo $SONGNUMBER | sed 's/^0*//')
        mkdir -p "/tmp/studyhymnal/metrics/"
        echo "$SONGNUMBER|$SONGTITLE" >> "/tmp/studyhymnal/metrics/$METRIC"
    fi 
done


METRICS=()
index=0;
cd "/tmp/studyhymnal/metrics/"
for i in `find ./`; do
    METRIC=$(echo $i | cut -c3-)
    METRICS[$index]=$METRIC
    echo $METRIC
    let "index++"
done

printf '%s\n' "${METRICS[@]}"
readarray -td '' SORTEDMETRICS < <(printf '%s\0' "${METRICS[@]}" | sort -z)

tmplocation=$(pwd)
cd $ROOTDIR
cd $DIR
cd ../

cp "templates/metricalindex.template.md" "indices/metricalindex.md" 
line=$(grep -n '# Metrical Index' indices/metricalindex.md | cut -d: -f 1)
let "line+=2"

cd "$tmplocation"
for i in "${SORTEDMETRICS[@]}"; do
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
        METRICR=$(echo $i| sed -e s/_/" "/g)
        # echo $LINE
        if [ !  -z  $SONGNUMBERSHORT  ]; then        
            sed -i "$line a $SONGNUMBERSHORT  | $METRICR | [$SONGTITLE](gitsongs/$SONGNUMBER.md) | $HYMNCOUNT" indices/metricalindex.md
            let "line++"
        fi
    done

    cd "$tmplocation"

    # printf '%s\n' "${SONGSSORTED[@]}"

done

