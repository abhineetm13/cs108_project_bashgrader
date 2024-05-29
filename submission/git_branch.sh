#!/usr/bin/env bash
# Arguments: none
# Output: A list of branches is printed and the current branch is indicated by "***"

################
# Checking if repository was initialised
if [ ! -f "git_config.txt" ]; then
    echo "Please initialize the repository first"
    exit
fi

###############
# Getting current details

repo_loc=$(grep "Repository location" ./git_config.txt | cut -d ":" -f 2)
current_branch=$(grep "Current branch" $repo_loc/current_head.txt | cut -d ":" -f 2)

################
# The list of branches is made in a temporary file _branches_list and printed 

ls -1 ${repo_loc}/branches > _branches_list
x=$IFS
IFS=$x
for branch in $(sed -E 's/(.*)\.txt/\1/g' _branches_list)
do
    if [ ${branch} == ${current_branch} ]; then
        echo "${branch} ***"
    else 
        echo ${branch}
    fi
done

rm _branches_list