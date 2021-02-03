#!/bin/bash

# Please name the script file beigining with _ for global service check(IAM/S3/Rout53/CF)

# Init Result
echo '' > /tmp/check_result.log

GLOBAL=0
REGION_NO=0
Not_Region_Name=1

if [ $# -eq 0 ]; then	# No argument, audit all region
	echo 
	echo No arguments specified, aduit all regions
	echo 
	# Get all region name
	for REGION in $(aws ec2 describe-regions --output text --query 'Regions[].[RegionName]')
	do
	    ((REGION_NO++))
	    # if [ $REGION_NO -ge 2 ]; then break; fi

	    echo '-------------------------------------------------'
	    echo '|   ['$REGION_NO']     Region: '$REGION
	    echo '-------------------------------------------------'
	    # Exec the rules
	    for f in ./rules/*.sh ;
	    do
		if [ -x "$f" ] && [ ! -d "$f" ]; then
		    if [ "$GLOBAL" -eq "1" ]; then	# Global service(IAM/S3/Rout53/CF) check has been done
			filename=${f##*/}
			if [ ${filename:0:1} != "_" ]; then	# No excute global service check
			    . $f
			fi
		    else			# Excute all rules
			. $f
		    fi
		fi
	    done
	    GLOBAL=1
	done

	printf "+++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
	printf "+++++++++++++*++++++   Summary   +++++++++*++++++++++\n"
	printf "+++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
	while read line
	do
	if [ "${line%,*}" == 1 ];then
	  echo -e "\033[41;36m ${line#*,} \033[0m"
	elif [ "${line%,*}" == 11 ]; then
	  echo -e "\033[41;36m     -- ${line#*,} \033[0m"
	else
	  echo ${line#*,}
	fi
	done  < /tmp/check_result.log
elif [ $# -gt 1 ]; then	# Too many argument, wrong
	echo 
	echo Too many arguments
	echo Usage: ./check.sh or ./check.sh [Region Name]
	echo 
else			# One argument specified
	# Get all region name
	for REGION in $(aws ec2 describe-regions --output text --query 'Regions[].[RegionName]')
	do
	    if [ ! $1 = $REGION ]; then	# skip
		continue;
	    else			# audit one region
		echo '-------------------------------------------------'
		echo '|   Region: '$REGION
		echo '-------------------------------------------------'
		# Exec the rules
		for f in ./rules/*.sh ;
		do
		    if [ -x "$f" ] && [ ! -d "$f" ]; then
		        if [ "$GLOBAL" -eq "1" ]; then	# Global service(IAM/S3/Rout53/CF) check has been done
		     	    filename=${f##*/}
			    if [ ${filename:0:1} != "_" ]; then	# No excute global service check
			        . $f
			    fi
			else			# Excute all rules
			    . $f
			fi
		    fi
		done

		printf "+++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
		printf "+++++++++++++*++++++   Summary   +++++++++*++++++++++\n"
		printf "+++++++++++++++++++++++++++++++++++++++++++++++++++++\n"

		# print alert information
		while read line
		do
		if [ "${line%,*}" == 1 ];then
		  echo -e "\033[41;36m ${line#*,} \033[0m"
		elif [ "${line%,*}" == 11 ]; then
		  echo -e "\033[41;36m     -- ${line#*,} \033[0m"
		else
		  echo ${line#*,}
	    	fi
		done  < /tmp/check_result.log
		echo '------------ Done ------------'
		Not_Region_Name=0
	        break;
	    fi
	done

	if [ $Not_Region_Name -ne 0 ]; then
	    echo
	    echo You specified a wrong Region Name !
	    echo Usage: ./check.sh or ./check.sh [Region Name]
	    echo
	fi
fi
