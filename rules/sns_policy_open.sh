#!/bin/bash

# result_code = 0, Miss, Safe
# result_code = 1, Hit, Danger
# result_code = 11, Danger Detail
# check if "ImageOwnerAlias" is tagged to the image

set +e
# printf "vvvvvvvvvv Execute Check - $(basename $0) Start: vvvvvvvvvv\n "

sns_topics=$(aws sns list-topics --query 'Topics' --region $REGION --output text)

result_code=0
result_msg="No SNS Topics with publicly open policy"
result_detail=""
flag=0
flag_sns_topic=""

for sns in ${sns_topics}; do
  flag_sns_topics="$sns"

  # Get the SNS Policy
  sns_topics_policy=$(aws sns get-topic-attributes --topic-arn ${sns} --query 'Attributes.Policy' --region $REGION --output text)

  # Check if There is the "Condition" Section In the Policy
  if_condition=$(echo $sns_topics_policy | jq -r '.Statement[]' | grep Condition | wc -l)

  # Check if There is the "Condition" Section In the Policy
  principal=$(echo $sns_topics_policy | jq -r '.Statement[].Principal[]')
  if [ $if_condition -eq 0 ] && [ "$principal" == "*" ]; then
    flag=1
    result_code=1
    result_msg="---> You are running SNS topic with publicly open policy !!!"
    result_detail=$result_detail"SNS-Topic:$sns"
  fi
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
