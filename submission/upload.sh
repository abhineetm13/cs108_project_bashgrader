#!/usr/bin/bash
# Uploads a new file to the current directory
# Argument: Address of file to be uploaded
# Output: File is copied to current directory

path_file=$1

file=$(basename $path_file) # name of file

if [ ! -f ${path_file} ]; then
	path=$(dirname ${path_file}) # directory path in which file is present
	echo "${file} was not found in ${path_file}. $(./suggestions.sh ${file} "$(ls -1 ${path})")"	
	exit
fi

if [ ! -f ${file} ]; then
	cp -f ${path_file} .
	echo "${file} uploaded from ${path_file}"
else
	echo "This file is already in the working directory. Do you want to replace it?(y/n)"
	read confirmation
	if [ ${confirmation,,} == "y" ]; then
		cp -f ${path_file} .
		echo "${file} uploaded from ${path_file}"
		echo "To see changes in main.csv, delete the existing main.csv and run "bash submission.sh combine""
	else
		exit
	fi
fi
