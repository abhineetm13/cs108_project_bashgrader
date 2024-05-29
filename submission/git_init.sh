#!/usr/bin/bash
# Initializes the git repository.
# The purpose of the file structure is mentioned in the report

repo_loc=$1
#if [ ! -d $1 ]; then
mkdir -p ${repo_loc}	
#fi

touch git_config.txt
echo 'Repository location:'$1'' > git_config.txt
# echo "user.name:" >> git_config.txt
# echo "user.email:" >> git_config.txt

mkdir -p ${repo_loc}/commits

mkdir -p ${repo_loc}/commits/master
rm -r -f ${repo_loc}/commits/master/*

mkdir -p ${repo_loc}/git_log
rm -f ${repo_loc}/git_log/*
touch ${repo_loc}/git_log/master.txt
echo "" > ${repo_loc}/git_log/master.txt

mkdir -p ${repo_loc}/branches
rm -f ${repo_loc}/branches/*
touch ${repo_loc}/branches/master.txt
echo -n "" > ${repo_loc}/branches/master.txt

touch ${repo_loc}/current_head.txt
echo "Current branch:master" > ${repo_loc}/current_head.txt
echo "Current commit:none" >> ${repo_loc}/current_head.txt
