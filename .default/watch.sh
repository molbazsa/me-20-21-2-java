#!/bin/bash


compile () {
    local file="$1"
    javac -d out "$file"
}


hasElement () {
    local element="$1"
    shift
    local list=("$@")
    for currentElement in "${list[@]}"
    do
        if [ "$currentElement" = "$element" ]
        then
            return 0
        fi
    done
    return 1
}


declare -A latestModifications


for file in `find src -type f -name '*.java'`
do
    latestModifications[$file]=`stat -c %Y $file`
done


while true
do
    for file in "${!latestModifications[@]}"
    do
        currentModification=`stat -c %Y $file`
        latestModification=${latestModifications[$file]}

        if [[ "$latestModification" != "$currentModification" ]]
        then
            echo "$file was modified"
            compile $file

            latestModifications[$file]=$currentModification
        fi
    done

    for file in `find src -type f -name '*.java'`
    do
        if ! hasElement $file "${!latestModifications[@]}"
        then
            echo "$file was added"
            compile $file

            latestModifications[$file]=`stat -c %Y $file`
        fi
    done

    sleep 0.3
done
