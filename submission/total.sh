#!/usr/bin/bash
# Arguments: none
# Output: A total column is created in main.csv

main="main.csv"

if [ ! -f ${main} ]; then
	echo "Please run "bash submission.sh combine" first."
	exit
fi

# If total column is already present, user confirmation is asked:
if [ $(head -1 ${main} | grep -c ,total$) -ne 0 ]; then
	echo "Total has already been calculated. Do you want to redo it?(y/n)"
	read confirmation
	if [ ${confirmation,,} != "y" ]; then
		exit
	else
		sed -i -E 's/(.*),(.*)$/\1/g' ${main} # The existing total column is removed
	fi
fi

ncolumns=$(head -1 main.csv | cut -d ',' --output-delimiter=" " -f 1- | wc -w) # Number of columns in main.csv
#echo $ncolumns
#if total column not present already, a new column is created:

awk -i inplace 'BEGIN {
	FS=","
	OFS="," 
}

{
	if(NR == 1) print $0 , "total"
	else {
		i = 3
		while(i <= '${ncolumns}') {
			if($i == "a") total = total + 0 
			else total = total + $i
			i = i + 1
		}
		print $0, total
	}
	total = 0
				
}' ${main}
