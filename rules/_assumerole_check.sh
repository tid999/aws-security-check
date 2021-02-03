#!/bin/bash

# result_code = 1, Have IAM role that allows assumption by external account
# result_code = 0, NO IAM role allows assumption by external account
# result_code = 11, IAM role Name

result_code=0
result_msg='No IAM role allows assumption by external account'
result_detail=""
flag=0

# Get my own aws account ID
Account_ID=`aws sts get-caller-identity --query 'Account' --output text`
# echo $Account_ID
roles=`aws iam list-roles --query 'Roles[*].RoleName' --output text`

for role in $roles
do
    ext_account_ID=`aws iam get-role --role-name $role --query 'Role.AssumeRolePolicyDocument.Statement[*].Principal.AWS' --output text | awk -F '::' '{print $2}' | awk -F ':' '{print $1}'`
    if [ -n "$ext_account_ID" ];then
        if [ "$Account_ID" != "$ext_account_ID" ] && [ ${role:0:8} != "Isengard" ]; then
	    flag=1
	    result_code=1
	    result_msg="---> You have IAM role that allows assumption by external account"
            result[${#result[@]}]=${role}
	    result_detail=$result_detail" IAMroleName:$role"
        fi 
    fi 
done

# There is a risk, Highlight It In The Screen
if [ $flag -eq 1 ]; then
    # Print Risk Item
    echo $result_code','$result_msg >>/tmp/check_result.log
    # Print All Detailed Risky Resources
    for dd in $result_detail
    do
        echo '11,'$dd >> /tmp/check_result.log
    done
fi

printf "%s\n" "$result_msg"
# printf "^^^^^^^^^^ Execute Check - $(basename $0) Completed. ^^^^^^^^^^\n "
