#!/usr/bin/env bash
# Various stats are calculated
# Argument: csv file name
# Output: Number of students, Mean, Median, Third quartile, Highest score, Standard deviation are printed

file=$1

# To check whether the file is present or not
if [ ! -f ${file} ]; then
	echo "File ${file} is not present in the directory. $(./suggestions.sh ${file} "$(ls -1)")"
	exit
fi

# To see if the file is main.csv or not
is_main=0
if [ "${file}" = "main.csv" ]; then
	is_main=1
fi

awk 'BEGIN {
	FS=","
	OFS=":"
	sum = 0
	num = 0
	square_sum = 0
}
{
	if(NR == 1) {
		# If the file is main.csv, it will check whether total was calculated or not
		if('${is_main}' != 0 && $NF !~ /total/) {
			print "Run bash submission.sh total first"
			exit 1
		}
	}
	if(NR != 1) {
		if($NF ~ /a/) {value = 0}
		else {value = $NF}
		sum = sum+value # sum of all marks
		square_sum = square_sum+(value**2) # sum of squares of marks
		num = num+1 # number of records
		totals[NR] = value # array of marks
		}	       
}
END {
	print "Number of students", num # Number of students

	if(num != 0) {

		n = asort(totals, sorted_totals)

		# to calculate median
		if (n%2 == 0)
			median = (sorted_totals[(n/2)] + sorted_totals[(n/2)+1])/2
		else if (n%2 == 1)
			median = sorted_totals[(n+1)/2]

		# to calculate third quartile

		if (n%4 == 3)
			third_quartile = (sorted_totals[(3*(n+1)/4)])
		else if (n%4 == 0)
			third_quartile = (3*sorted_totals[3*(n)/4] + sorted_totals[(3*(n)/4)+1])/4
		else if (n%4 == 1)
			third_quartile = (sorted_totals[(3*(n-1)/4)+1] + sorted_totals[(3*(n-1)/4)+2])/2
		else if (n%4 == 2)
			third_quartile = (3*sorted_totals[(3*(n-2)/4)+2] + sorted_totals[(3*(n-2)/4)+3])/4

		mean=sum/num
		sq_avg = square_sum/num
		std_dev = sqrt(sq_avg-(mean**2))
		highest = sorted_totals[n]

		print "Mean", mean
		print "Median", median
		print "Third Quartile", third_quartile
		print "Highest", highest
		print "Std Dev", std_dev
	}
}' ${file}

