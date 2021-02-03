#!/bin/bash

# result_code = 0, Miss, Safe
# result_code = 1, Hit, Danger
# result_code = 11, Danger Detail
# check if "ImageOwnerAlias" is tagged to the image

set +e
# printf "vvvvvvvvvv Execute Check - $(basename $0) Start: vvvvvvvvvv\n "

glacier_vault=$(aws glacier list-vaults --account-id - --query 'VaultList[].VaultName' --region $REGION --output text)

result_code=0
result_msg="No glacier with publicly open policy"
result_detail=""
flag=0
flag_glacier_vault=""

for glacier in ${glacier_vault}; do
  flag_sns_topics="$glacier"

  glacier_policy=$(aws glacier get-vault-access-policy --account-id - --vault-name ${glacier} --query 'policy' --region $REGION --output text)

  if_condition=$(echo $glacier_policy | jq -r '.Statement[]' | grep Condition | wc -l)
  principal=$(echo $glacier_policy | jq -r '.Statement[].Principal[]')
  if [ $if_condition -eq 0 ] && [ "$principal" == "*" ]; then
    flag=1
    result_code=1
    result_msg="---> You are running Glacier with publicly open policy !!!"
    result_detail=$result_detail"Glacier-Vault:$glacier"
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
