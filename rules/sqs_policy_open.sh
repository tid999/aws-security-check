#!/bin/bash

# result_code = 0, Miss, Safe
# result_code = 1, Hit, Danger
# result_code = 11, Danger Detail
# check if "ImageOwnerAlias" is tagged to the image

set +e
# printf "vvvvvvvvvv Execute Check - $(basename $0) Start: vvvvvvvvvv\n "

sqs_queues=$(aws sqs list-queues --query 'QueueUrls' --region $REGION --output text)

result_code=0
result_msg="No SQS with publicly open policy"
result_detail=""
flag=0
flag_sqs_queues=""

for sqs in ${sqs_queues}; do
  if [ $sqs != "None" ]; then
    flag_sqs_queues="$sqs"

    # Get the SQS Queue Policy
    sqs_queue_policy=$(aws sqs get-queue-attributes --queue-url ${sqs} --attribute-names Policy --query 'Attributes.Policy' --region $REGION --output text)

    if [ "${sqs_queue_policy}" != "None" ]; then
      # Check if There is the "Condition" Section In the Policy
      condition=$(echo $sqs_queue_policy | jq -r '.Statement[]' | grep Condition | wc -l)

      # Check if There is the "Pricinpal *" Section In the Policy
      principal=$(echo $sqs_queue_policy | jq -r '.Statement[]|{Principal:.Principal}' | grep "*" | wc -l)

      if [ $principal -gt $condition ] && [ $principal -gt 0 ]; then
        flag=1
        result_code=1
        result_msg="---> You are running SQS Queue with publicly open policy !!!"
        result_detail=$result_detail"SQS:$sqs"
      fi
    fi
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
