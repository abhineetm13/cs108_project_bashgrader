#!/usr/bin/bash

input=$1 # command

if [ "${input,,}" = "combine" ]; then
	if [ $# -eq 1 ]; then
		bash combine.sh
	elif [ $# -eq 3 ]; then
		bash combine.sh $2 $3
	else
		echo "Wrong format. Usage: bash submission.sh combine (or) bash submission.sh combine -f <files_list>"
	fi

elif [ "${input,,}" = "upload" ]; then
	if [ $# -eq 2 ]; then
		bash upload.sh $2
	else
		echo "Wrong format. Usage: bash submission.sh upload <file_path>"
	fi

elif [ "${input,,}" = "total" ]; then
    if [ $# -eq 1 ]; then
		bash total.sh
	else
		echo "Wrong format. Usage: bash submission.sh total"
	fi

elif [ "${input,,}" = "stats" ]; then
	if [ $# -eq 2 ]; then
		bash stats.sh $2
	else 
		echo "Wrong format. Usage: bash submission.sh stats <file name>"
	fi 

elif [ "${input,,}" = "graph" ]; then	
	if [ $# -eq 2 ]; then
		if [ ! -f "main.csv" ]; then
    		echo "main.csv is not present. Please run "bash submission.sh combine" first"
    		exit
		fi
		if [ -f "$2" ]; then
			./graph.sh $2
		else 
			echo "File $2 is not present in the directory. $(./suggestions.sh $2 "$(ls -1)")"
		fi
	else 
		echo "Wrong format. Usage: bash submission.sh graph <file name>"
	fi

elif [ "${input,,}" = "update" ]; then
	if [ $# -eq 1 ]; then 
		bash update.sh
	else 
		echo "Wrong format. Usage: bash submission.sh update"
	fi

elif [ "${input,,}" = "view" ]; then
	if [ $# -eq 2 ]; then	
		bash student_view.sh $2
	else 
		echo "Wrong format. Usage: bash submission.sh view <roll number>"
	fi

elif [ "${input,,}" = "git_init" ]; then
	if [ $# -eq 2 ]; then
		bash git_init.sh $2
	else
		echo "Wrong format. Usage: bash submission.sh git_init <path>"
	fi	

elif [ "${input,,}" = "git_commit" ]; then
	if [ $# -eq 3 ]; then
		if [ "$2" = "-m" ]; then
			bash git_commit.sh $3
		fi
	elif [ $# -eq 1 ]; then
		bash git_commit.sh
	else
		echo 'Wrong format!'
	    echo 'Usage: "bash submission.sh git_commit -m message" or "bash submission.sh git_commit"'
	fi

elif [ "${input,,}" = "git_checkout" ]; then
	if [ $# -eq 3 ]; then
		if [ "$2" = "-b" ]; then
			bash git_checkout_branch.sh $3
		elif [ "$2" = "-m" ]; then
			bash git_checkout.sh $2 $3
		else
			echo "Wrong format!"
			echo "Usage: "bash submission.sh git_checkout -b branch" (or) bash submission.sh git_checkout -m message"
		fi
	else
		bash git_checkout.sh $2
	fi

elif [ "${input,,}" = "git_branch" ]; then
	if [ $# -eq 1 ]; then
		bash git_branch.sh
	else 
		echo "Wrong format. Usage: bash submission.sh git_branch"
	fi

elif [ "${input,,}" = "git_log" ]; then
	if [ $# -eq 1 ]; then	
		bash git_log.sh
	else
		echo "Wrong format. Usage: bash submission.sh git_log"
	fi
else 
	echo "The mentioned command does not exist. $(./suggestions.sh ${input,,} "$(echo -e "combine\nupload\ntotal\nupdate\nstats\ngraph\nview\ngit_init\ngit_commit\ngit_checkout\ngit_log\ngit_branch")")"
fi
