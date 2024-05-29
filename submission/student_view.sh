#!/usr/bin/env bash
# The records of a single student are printed, as present in main.csv
# Arguments: Roll number
# Output: Various marks of the student, each exam marks are shown in a different line

rollno=$1
main="main.csv"

if [ ! -f ${main} ]; then
    echo "main.csv is not present. Please run "bash submission.sh combine" first"
    exit
fi

if [ $(grep -c ^${rollno}, ${main}) -eq 1 ]; then
    awk '
        BEGIN {
            FS=","
            OFS=": "
        }
        (NR == 1) {
            for(i=1; i<=NF; i++) {
                headings[i]=$i # headings are stored
            }
        }
        /'${rollno}'/ {
            for(i=1; i<=NF; i++) {
                values[i]=$i # values are stored
            }
        }
        END {
            PROCINFO["sorted_in"] = "@ind_num_asc" # this is used to preserve the order of columns
            for (i in headings)
                print headings[i], values[i] # printing the values
        }
    ' ${main}
    
elif [ $(grep -c ^${rollno}, ${main}) -eq 0 ]; then
    echo "This roll number does not have an entry. $(./suggestions.sh ${rollno} "$(cut -d "," -f 1 ${main})")"
fi 