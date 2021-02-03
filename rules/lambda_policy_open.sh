#!/bin/bash

# result_code = 0, Miss, Safe
# result_code = 1, Hit, Danger
# result_code = 11, Danger Detail
# check if "ImageOwnerAlias" is tagged to the image

set +e
# printf "vvvvvvvvvv Execute Check - $(basename $0) Start: vvvvvvvvvv\n "

lambda_function=$(aws lambda list-functions --query 'Functions[].FunctionName' --region $REGION --output text)

result_code=0
result_msg="No lambda publicly open policy"
result_detail=""
flag=0
flag_lambda_function=""

for lambda in ${lambda_function}; do
  # if [ $lambda != " " ]; then
    flag_lambda_function="$lambda"

    lambda_policy=$( aws lambda get-policy --function-name ${lambda} --query 'Policy' --region $REGION --output text >/dev/null 2>&1)
    if [ $? -eq 0 ];then
      if_condition=$(echo $lambda_policy | jq -r '.Statement[]' | grep Condition | wc -l)
      principal=$(echo $lambda_policy | jq -r '.Statement[].Principal[]')
      if [ $if_condition -eq 0 ] && [ "$principal" == "*" ]; then
        flag=1
        result_code=1
        result_msg="---> You are running Lambda with publicly open policy !!!"
        result_detail=$result_detail"Lambda-Function:$lambda"
      fi
    fi
  # fi
done

# There is a risk, highlight it in the screen
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
