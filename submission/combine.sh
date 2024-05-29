#!/usr/bin/env bash
# Arguments: none (or) -f <files_list>
# Output: main.csv is created/updated

###########################
# For getting the list of files

if [ $# -eq 0 ]; then
    files_list="files_list.txt"
    echo -n "" > ${files_list}

    x=$IFS
    IFS=$'\n'
    for file in $(ls -1 *.csv)
    do
        echo ${file} >> ${files_list}
    done
    IFS=$x
    sed -i '/^main.csv$/ d' ${files_list}
elif [ $# -eq 2 ] && [ $1 == "-f" ]; then
    files_list="$2"
    rm -f main.csv
    if [ ! -f ${files_list} ]; then
        echo "The mentioned file is not present. $(./suggestions.sh ${files_list} "$(ls -1 *.*)")"
        exit
    fi
else 
    echo "Wrong format. Usage: bash submission.sh combine (or) bash submission.sh combine -f <files_list>"
    exit
fi

# main stores the name of main.txt
main="main.csv"

#########################
# To initialize main file if it has not been done already
if [ ! -f ${main} ] || [ $(cat ${main} | wc -l ) -eq 0 ]; then
    echo "Roll_Number,Name" > $main
fi

##############################
# To remove total column at the end of main.txt, if total was done before
declare -i is_total_there=$(head -1 $main | grep -c ,total$)
if [ ${is_total_there} -ne 0 ]; then
    #echo hi
    sed -i -E 's/(.*),(.*)$/\1/g' ${main}
fi

function combine { 
    # Takes file as argument and updates main.csv with it
    local IFS="," # This is used for read
    file=$1

    declare -i oldprevtests=$(awk 'BEGIN { FS="," } {if (NR == 1) print (NF-3)}' ${main})
    # "oldprevtests" is the number of files combined before the current one
    absent=""
    for (( i=0 ; i<${oldprevtests} ; i++ ));
    do
        absent=${absent}",a" # This string will be used if a roll number appears for the first time in the current file 
    done

    # If a roll no is not present, an entry is created, else the existing entry is updated
    while read -r rollno name marks
    do
        present=$(grep -c ${rollno} ${main})     
        if [ ${present} -eq 0 ]; then
            echo -n "${rollno},${name}" >> ${main}
            echo "${absent},${marks}" >> ${main}
        elif [ ${present} -eq 1 ]; then
            sed -i -E "1 ! s/${rollno}(.*)/&,${marks}/" ${main}
        fi
    done < ${file}

    # Roll numbers which are not there in the current file are marked 'a'
    while read -r rollno name marks
    do
        declare -i newprevtests=$(echo ${marks[0]} | cut -d ' ' -f 1- | wc -w) # number of marks recorded for a roll no after previous step
        #echo $oldprevtests $newprevtests ${entry[1]}
        #echo $entry
        if [ ${newprevtests} -eq ${oldprevtests} ]; then
            sed -i "1 ! s/${rollno[@]},${name[@]},${marks[@]}/&,a/" ${main}
        fi
    done < ${main}

}

echo "Files combined:"
x=$IFS
IFS=$'\n'
for filename in $(sed -E 's/(.*)\.csv/\1/g' ${files_list}) # Goes through all files in files_list
do
    # File is combined only if it is not already present in main.csv
    if [ -f ${filename}.csv ]; then
        if [ "$(head -1 ${filename}.csv)" = "Roll_Number,Name,Marks" ]; then
            if [ $(head -1 $main | grep -c ,${filename},) -eq 0 ] && [ $(head -1 $main | grep -c ,${filename}$) -eq 0 ]; then
                echo "${filename}.csv"
                sed -i '1s/\(.*\)/&,'${filename}'/' $main
                combine ${filename}.csv
            fi
        else
            echo "${filename}.csv --> Wrong format"
        fi
    else 
        echo "${filename}.csv --> Not present in directory"
    fi    
done
IFS=$x

# For re-calculating total if it was there before
if [ ${is_total_there} -ne 0 ]; then
    bash total.sh
fi