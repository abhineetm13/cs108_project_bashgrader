#!/usr/bin/env bash
# Commits the present working directory to repo
# Arguments: Commit Message
# Output: List of changes and deletions from the previous commit


####################
# To make sure git_init was executed
if [ ! -f git_config.txt ]; then
	echo "Please initialise the git_repo first"
	echo "You may want to run "bash submission.sh git_init < repo_address >""
	exit
fi

###################
# Code for taking commit message

if [ $# -ne 0 ]; then
	message=$@
else
	echo -e "Enter the commit message below:"
	read message
fi
#echo $message

###################
# To generate hash

git_hash=$(bash ./git_hash.sh)

###################
# Getting repo and commit details

repo_loc=$(grep "Repository location" ./git_config.txt | cut -d ":" -f 2)

new_commit_loc=${repo_loc}/commits/${git_hash} # Location of the folder in which new commit is stored
prev_commit=$(grep "Current commit" ${repo_loc}/current_head.txt | cut -d ":" -f 2) # Hash of the previous commit
this_branch=$(grep "Current branch" ${repo_loc}/current_head.txt | cut -d ":" -f 2) # Current branch

######################
# To ensure that commit is not tried from the middle of a branch

last_commit=$(tail -1 ${repo_loc}/branches/${this_branch}.txt) # Last commit of current branch
if [ ${prev_commit} != "none" ] && [ ${prev_commit} != ${last_commit} ]; then
    echo 'Please create a branch using "bash submission.sh git_checkout -b <branch>" to make commits from here'
    exit
fi

#####################
# Creating structure of the commit folder and storing commit details

mkdir ${new_commit_loc}
touch ${new_commit_loc}/prev_commit.txt
touch ${new_commit_loc}/message.txt
touch ${new_commit_loc}/branch.txt
mkdir -p ${new_commit_loc}/changes

echo ${prev_commit} > ${new_commit_loc}/prev_commit.txt
echo ${message} > ${new_commit_loc}/message.txt
echo ${this_branch} > ${new_commit_loc}/branch.txt

#####################
# Printing commit details

echo "Commit hash: "${git_hash}
echo "Branch: "${this_branch}

########################
# Case 1: First commit of repo(prev_commit = "none"): All files are copied
# Case 2: Commit at the end of the current branch(prev_commit = last commit): diff of each file is stored
# Case 3: First commit of a branch, ***Not handled by this code***
#   Will occur when commit is tried from from the middle of a branch, prev_commit != ("none" or last commit of branch)
#   Error should be given to use "bash submission.sh git_checkout -b message"

if [ ${prev_commit} == "none" ]; then

	# Copying all files of current directory to ${new_commit_loc}/changes/,
	# printing the names of files which changed
	# and printing the number of files changed
	declare -i nChanged=0
	echo "Changed files:"
    x=$IFS
	IFS=$'\n'
	for line in $(ls -1 *) # line represents a file
	do
		if [ -f ${line} ]; then
			cp -f ${line} ${new_commit_loc}/changes/${line}
			echo ${line}
			nChanged+=1
		fi
	done
	IFS=$x
	echo ""
	echo "$nChanged files changed"

elif [ ${prev_commit} == ${last_commit} ]; then
	# Storing diff of all files of current directory from prev_commit to ${new_commit_loc}/changes/,
	# printing the names of files which changed and were removed
	# and printing the number of files changed and removed

	declare -i nChanged=0
	echo "Changed files:"
    x=$IFS
	IFS=$'\n'
	for line in $(ls -1 *) # line represents a file
	do
		if [ -f ${repo_loc}/commits/${prev_commit}/changes/${line} ]; then
			bash ./git_patch.sh ${line} ${prev_commit} ${this_branch}
			diff ${repo_loc}/commits/patch_temp.txt ${line} > ${new_commit_loc}/changes/$line
			if [ $(cat ${new_commit_loc}/changes/${line} | wc -l) -ne 0 ]; then
				echo ${line}
				nChanged+=1
			fi
		else
			cp -f ${line} ${new_commit_loc}/changes/$line
			echo $line
			nChanged+=1
		fi
	done
	IFS=$x

	echo ""
	echo "${nChanged} files changed"

	declare -i nDeleted=0
	x=$IFS
	IFS=$'\n'
	for line in $(ls -1 ${repo_loc}/commits/${prev_commit}/changes)
	do	
		if [ ! -f ./${line} ]; then
			nDeleted+=1
		fi
	done
	echo "${nDeleted} files deleted" 

fi

#####################
# Bookkeeping

sed -i -E '2 s/Current commit:(.*)/Current commit:'${git_hash}'/' ${repo_loc}/current_head.txt
echo ${git_hash} >> ${repo_loc}/branches/${this_branch}.txt

# Updating git_log of current branch

git_log=${repo_loc}/git_log/${this_branch}.txt
sed -i '1i commit '${git_hash}'' ${git_log}
sed -i '1a \ ' ${git_log}
sed -i '1a \	'${message}'' ${git_log}
sed -i '1a \ ' ${git_log}