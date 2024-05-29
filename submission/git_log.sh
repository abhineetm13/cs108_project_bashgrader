#!/usr/bin/env bash
# Arguments: none
# Output: The commit log of the current branch is printed until the current commit
# For each commit in the branch, the hash and the commit message is printed. 
# Commit are shown in reverse-chronological order, i.e., the latest commit is shown first.

################
# Checking if repository was initialised
if [ ! -f "git_config.txt" ]; then
    echo "Please initialize the repository first"
    exit
fi

#######################
# The file in repo_loc/git_log corresponding to current commit is printed from the current commit till the first commit

repo_loc=$(grep "Repository location" ./git_config.txt | cut -d ":" -f 2)

current_commit=$(grep "Current commit" $repo_loc/current_head.txt | cut -d ":" -f 2)
current_branch=$(grep "Current branch" $repo_loc/current_head.txt | cut -d ":" -f 2)

sed -n '/^commit '${current_commit}'$/,$ p' ${repo_loc}/git_log/${current_branch}.txt