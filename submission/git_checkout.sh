#!/usr/bin/env bash
# Checks out the mentioned commit
# Arguments: Commit hash (any number of digits is fine as long as it is unique) or "-m commit-message"

####################
# To make sure git_init was executed
if [ ! -f git_config.txt ]; then
	echo "Please initialise the git_repo first"
	echo "You may want to run "bash submission.sh git_init < repo_address >""
	exit
fi


#####################
# Getting repo details

repo_loc=$(grep "Repository location" ./git_config.txt | cut -d ":" -f 2)
current_branch=$(grep "Current branch" $repo_loc/current_head.txt | cut -d ":" -f 2)
current_commit=$(grep "Current commit" ${repo_loc}/current_head.txt | cut -d ":" -f 2)

####################
# Checking if a commit was made
if [ "${current_commit}" == "none" ]; then
    echo "The repository has no commits."
    exit
fi

###############
#Code for getting hash from first few digits:
# I am assuming that commit messages are single-line
# I am assuming that no message is part of another message

if [ $# -eq 1 ]; then
    commitno=$1
    if [ $(ls -1 ${repo_loc}/commits | grep -c ^${commitno}) -eq 1 ]; then
        commithash=$(ls -1 ${repo_loc}/commits | grep ^${commitno})
    elif [ $(ls -1 ${repo_loc}/commits | grep -c ^${commitno}) -gt 1 ]; then
        echo "Multiple commit hashes start with this string. Please enter some more digits."
        exit
    else
        echo "There is no hash beginning with this string."
        exit
    fi
elif [ $# -eq 2 ] && [ "$1" == "-m" ]; then
    shift
    message=$@

    declare -i occurences=0
    x=$IFS
    IFS=$'\n'
    for line in $(ls -1 ${repo_loc}/git_log)
    do
        if [ $(grep -c $'\t'${message} ${repo_loc}/git_log/${line}) -eq 1 ]; then
            commithash=$(sed '/^\t'${message}'/ q' ${repo_loc}/git_log/${line} | tail -3 | head -1 | cut -d " " -f 2) 
            occurences+=1
        else
            echo "Multiple commits have this message. You may try using the hash number"
            exit
        fi
    done
    IFS=$x

    if [ ${occurences} -eq 0 ]; then
        echo "No commit has this message"
        exit
    elif [ ${occurences} -gt 1 ]; then
        echo "Multiple commits have this message. You may try using the hash number"
        exit
    fi
fi

#####################
# To ensure that the head gets preserved
if [ ${current_commit} == $(tail -1 ${repo_loc}/branches/${current_branch}.txt) ]; then
    cp -r -f * ${repo_loc}/commits/${current_branch}/
    # echo "hi"
fi

##############
# Method followed for checkout:
# If current_commit is the last commit of current branch :
#   Copy all files to repo_loc/commits/current_branch, 
#   then remove all files from working dir,
#   then patch and copy files from commit to working dir.
# Else :
#   Give warning that any changes made will be lost, ask confirmation
#   If yes : Proceed as above      
#   Else: exit 

branch=$(head -1 ${repo_loc}/commits/${commithash}/branch.txt)
tempfile=${repo_loc}/commits/patch_temp.txt
commits_list=$(cat ${repo_loc}/branches/${branch}.txt)


if [ ${current_commit} == $(tail -1 ${repo_loc}/branches/${current_branch}.txt) ]; then
    confirmation="y"
else
    echo "Any changes made from this commit will be lost. Confirm if you want to proceed(y/n)"
    read confirmation
fi

#echo ${confirmation}
if [ ${confirmation,,} == "y" ]; then
    echo "Switching to ${commithash}"
    rm -rf *

    x=$IFS
    IFS=$'\n'
    for line in $(ls -1 ${repo_loc}/commits/${commithash}/changes)
    do
        rm -f ${tempfile}
        if [ -f ${repo_loc}/commits/${commithash}/changes/${line} ]; then
            #echo $line
            #bash ./git_patch.sh ${line} ${commithash} ${branch}
            for commit in ${commits_list} 
            do
                if [ -f ${repo_loc}/commits/${commit}/changes/${line} ]; then
                    if [ -f $tempfile ]; then
                        patch -s $tempfile ${repo_loc}/commits/${commit}/changes/${line} 
                    else
                        #pwd
                        echo -n "" > ${tempfile}
                        cp -f ${repo_loc}/commits/${commit}/changes/${line} ${tempfile}
                    fi
                else
                    if [ -f ${tempfile} ]; then
                        rm -f ${tempfile}
                    fi
                fi

                if [ ${commit} == ${commithash} ]; then  # to ensure that patching is done only until the mentioned commit
                    break
                fi

            done
            cp -f ${tempfile} ./${line}
        #else
            #echo 1 $line
        fi
    done
    IFS=$x

    chmod 744 *.sh
else
    exit
fi

#####################
# Bookkeeping
sed -i -E '1 s/Current branch:(.*)/Current branch:'${branch}'/' ${repo_loc}/current_head.txt
sed -i -E '2 s/Current commit:(.*)/Current commit:'${commithash}'/' ${repo_loc}/current_head.txt
