#!/usr/bin/env bash

# Creates a file of a commit and stores it in repo/commits/patch_temp.txt
# File is made by patching up the diff stored in each commit one after the other
# This progam should be called from project folder

################
# Assigning variables to arguments
# Arguments: Filename, Commit Number, Branch of the commit

file=$1
commitno=$2
branch=$3


#################
# Getting repo location and other data. Also, patch_temp is removed.

repo=$(grep "Repository location" ./git_config.txt | cut -d ":" -f 2)
commits=$repo/commits
commits_list=$(cat ${repo}/branches/${branch}.txt) # List of all commits in the branch
tempfile=${repo}/commits/patch_temp.txt
rm -f $tempfile
#echo -n "" > $tempfile
#################
# Patching is done by traversing along all the previous commits of the branch.
# Patched file is in "repo/commits/patch_temp.txt"

for commit in $commits_list 
do
	if [ -f $commits/$commit/changes/$file ]; then
		if [ -f $tempfile ]; then
			patch -s $tempfile $commits/$commit/changes/$file 
		else
			#pwd
			echo -n "" > $tempfile
			cp $commits/$commit/changes/$file $tempfile
		fi
	else
		if [ -f $tempfile ]; then
			rm -f $tempfile
		fi
	fi

	if [ $commit = $commitno ]; then  # to ensure that patching is done only until the mentioned commit
		break
	fi

done

