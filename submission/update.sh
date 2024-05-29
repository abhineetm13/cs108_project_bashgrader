#!/usr/bin/env bash
# Updates main.csv and the corresponding file with updated marks
# Arguments: none
# User must input filename, roll number and updated marks as prompted
# Output: Marks corresponding to the roll number are updated in main.csv and the file  

main=main.csv

if [ ! -f ${main} ]; then
    echo "main.csv is not present. Please run "bash submission.sh combine" first"
    exit
fi

# Checking if main.csv has a total column.
if [ $(head -1 $main | grep -c ,total$) -ne 0 ]; then
    is_total_there=1
else
    is_total_there=0
fi

file="0"
echo "Input the file name below. To stop, input -q."
while :
do
    echo -n "File Name (excluding extension): "
    read file

    if [ ${file} == "-q" ]; then
        break
    fi

    if [ -f ./$file.csv ]; then
        rollno="0"
        echo "Input the details below. To stop, input -q as the Roll Number."
        while :
        do  
            echo -n "Roll Number: "
            read rollno

            if [ ${rollno} == "-q" ]; then
                break
            fi

            if [ $(grep -c -E -e "^${rollno}," $main) -eq 1 ]; then 
                
                
                if [ $(grep -c -E -e "^${rollno}," ${file}.csv) -eq 1 ]; then 
                    echo -n "Updated Marks: "
                    read marks

                    awk -i inplace 'BEGIN {
                        FS=","
                        OFS=","
                    }
                    {	
                        if ($1 ~ /'$rollno'/) {
                            print $1, $2, '$marks'
                        }
                        else print $0 
                    }' $file.csv
                else # if a roll number has no entry in a file, a new record can be created
                    echo -n "This roll number does not have an entry in ${file}.csv. Do you want to create a new record?(y/n) "
                    read confirmation
                    if [ ${confirmation,,} == "y" ]; then
                        name="$(grep -E -e "^${rollno}," ${main} | cut -d "," -f 2)"
                        echo "Name: ${name}"
                        echo -n "Marks: "
                        read marks
                        echo "${rollno},${name},${marks}" >> ${file}.csv
                        echo "Record created!"
                    else
                        continue
                    fi
                fi
            
                awk -i inplace 'BEGIN {
                    FS=","
                    OFS=","
                    col=0
                    is_total_there='${is_total_there}'
                }
                {
                    if (NR == 1) {
                        for ( i=1; i<= NF; i++) {
                            if( $i ~ /'$file'/ ) {
                                col = i
                            }
                        }	
                    }
                }
            
                {
                    if ($1 ~ /'$rollno'/) {
                        if ( is_total_there == 1 ) { # total column is also updated
                            $NF+=('$marks'-$col)
                        }
                        $col='$marks'
                        print $0
                    }
                    else {print $0} 
                }' $main
            else
               	echo -e 'This is not a valid roll number. '$(./suggestions.sh ${rollno} "$(cut -d "," -f 1 ${main})")''
            fi
        done
    else    
    	echo -e 'This file name is not present in this folder. '$(./suggestions.sh ${file} "$(ls -1 *.* | cut -d "." -f 1)")''	
    fi
done

