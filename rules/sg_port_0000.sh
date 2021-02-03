#!/bin/bash

# result_code = 0, Miss, Safe
# result_code = 1, Hit, Danger
# result_code = 11, Danger Detail

result_code=0
result_msg="No world wide open port found in security groups."
result_detail=""
flag=0
ports=""
AWS_CMD=""

# printf "vvvvvvvvvv Execute Check - $(basename $0) Start: vvvvvvvvvv\n "

# Get all ports to be checked
while read line
do
    if [[ $line == "" || $line == \#* ]] ;then
      continue
    else
      if [ -z $ports ]; then
	 ports=$line
      else
	ports=$ports",$line"
      fi
    fi
done  < ./rules/sg_port_0000.properties

    AWS_CMD="aws ec2 describe-security-groups --filters Name=ip-permission.to-port,Values=$ports Name=ip-permission.cidr,Values='0.0.0.0/0' --query "SecurityGroups[*].[GroupId]" --region $REGION --output text"
    check_results=`$AWS_CMD`
    array=(${check_results// / })
    # echo ${#array[*]}
    if [ "${#array[*]}" -gt "0" ];then
      result_code=1
      result_msg="---> You have services with ports that are open to the world !!!"
      printf "%s\n" "$result_msg"
      echo $result_code','$result_msg >> /tmp/check_result.log
    fi

    for dd in $check_results
    do
      echo '11,'[$REGION]-SecurityGroup-Id:$dd >> /tmp/check_result.log
    done

printf "%s\n" "$result_msg"
# printf "^^^^^^^^^^ Execute Check - $(basename $0) Completed. ^^^^^^^^^^\n "
