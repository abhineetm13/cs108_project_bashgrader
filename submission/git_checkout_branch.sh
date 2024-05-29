#!/usr/bin/env bash
# Arguments: branch name
# Output: The working directory is checked out to the mentioned branch
# If the branch does not already exist, a new branch is created

branch=$1

################
# Checking if repository was initialised
if [ ! -f "git_config.txt" ]; then
    echo "Please initialize the repository first"
    exit
fi


###############
# Getting current details

repo_loc=$(grep "Repository location" ./git_config.txt | cut -d ":" -f 2)
current_commit=$(grep "Current commit" $repo_loc/current_head.txt | cut -d ":" -f 2)
current_branch=$(grep "Current branch" $repo_loc/current_head.txt | cut -d ":" -f 2)

####################
# Checking if a commit was made
if [ ${current_commit} == "none" ]; then
    echo "The repository has no commits."
    exit
fi

#####################
# If the branch exists, 
#   If the current commit is at the end of the current branch, 
#       The current directory is copied to repo_loc/commits/<current_branch>
#       Checkout is carried out       
#   If the current commit is in the middle of the current branch, 
#       User is informed that changes made from the current commit will be lost, comfirmation is asked.
#       If user confirms, checkout is carried out
# If the branch does not exist,
#   A new branch is created

if [ -f ${repo_loc}/branches/${branch}.txt ]; then
    if [ ${current_commit} == $(tail -1 ${repo_loc}/branches/${current_branch}.txt) ]; then
        rm -f -r ${repo_loc}/commits/${current_branch}/*
        cp -f -r * ${repo_loc}/commits/${current_branch}
        confirmation="y"
    else
        echo "Any changes made from this commit will be lost. Confirm if you want to proceed(y/n)"
        read confirmation
    fi

    if [ ${confirmation,,} == "y" ]; then
        rm -rf *
        cp -f ${repo_loc}/commits/${branch}/* .
        branch_last_commit=$(tail -1 ${repo_loc}/branches/${branch}.txt)
        sed -i -E '2 s/Current commit:(.*)/Current commit:'${branch_last_commit}'/' ${repo_loc}/current_head.txt
    fi
else
    if [ ${current_commit} == $(tail -1 ${repo_loc}/branches/${current_branch}.txt) ]; then
        rm -f -r ${repo_loc}/commits/${current_branch}/*
        cp -f -r * ${repo_loc}/commits/${current_branch}
    fi

    touch ${repo_loc}/git_log/${branch}.txt
    bash git_log.sh > ${repo_loc}/git_log/${branch}.txt

    touch ${repo_loc}/branches/${branch}.txt
    sed '/'${current_commit}'/ q' ${repo_loc}/branches/${current_branch}.txt > ${repo_loc}/branches/${branch}.txt

    mkdir -p ${repo_loc}/commits/${branch}
    rm -f -r ${repo_loc}/commits/${branch}/*

    echo ${branch} >> ${repo_loc}/commits/${current_commit}/branch.txt

    echo "Branch '${branch}' created."
fi

sed -i -E '1 s/Current branch:(.*)/Current branch:'${branch}'/' ${repo_loc}/current_head.txt

echo "Switching to branch '${branch}'."
