#!/bin/bash

# result_code = 0, Miss, Safe
# result_code = 1, Hit, Danger
# result_code = 11, Danger Detail
# check if "ImageOwnerAlias" is tagged to the image

set +e
# printf "vvvvvvvvvv Execute Check - $(basename $0) Start: vvvvvvvvvv\n "

kms_keys=$(aws kms list-keys --query 'Keys[].KeyId' --region $REGION --output text)

result_code=0
result_msg="No KMS with publicly open policy"
result_detail=""
flag=0
flag_sqs_queues=""

for kms in ${kms_keys}; do
  flag_kms_keys="$kms"
  kms_policyname=$(aws kms list-key-policies --key-id ${kms} --query 'PolicyNames' --region $REGION --output text 2>/dev/null )
  if [ $?  -gt 1 ]; then continue; fi
  kms_policy=$(aws kms get-key-policy --key-id ${kms} --policy-name ${kms_policyname} --region $REGION --output text 2>/dev/null )
  if [ $?  -gt 1 ]; then continue; fi
  condition=$(echo $kms_policy | jq -r '.Statement[]' | grep Condition | wc -l)
  principal=$(echo $kms_policy | jq -r '.Statement[]|{Principal:.Principal}' | grep "*" | wc -l)
  if [ $principal -gt $condition ] && [ $principal -gt 0 ]; then
    flag=1
    result_code=1
    result_msg="---> You are running KMS with publicly open policy !!!"
    result_detail=$result_detail"KMS:$kms"
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
