#!/bin/bash

# result_code = 0, Miss, Safe
# result_code = 1, Hit, Danger
# result_code = 11, Danger Detail
# check if "ImageOwnerAlias" is tagged to the image

set +e
# printf "vvvvvvvvvv Execute Check - $(basename $0) Start: vvvvvvvvvv\n "

es_domains=$(aws es list-domain-names --query 'DomainNames[].DomainName' --region $REGION --output text)

result_code=0
result_msg="No elasticsearch service domain with publicly open policy"
result_detail=""
flag=0
flag_es_domain=""

for esdomain in ${es_domains}; do
  flag_es_domain="$esdomain"

  # Get the ES Domain Policy
  es_domain_policy=$(aws es describe-elasticsearch-domain-config --domain-name ${esdomain} --query 'DomainConfig.AccessPolicies.Options' --region $REGION --output text)

  # Check if There is the "Condition" Section In the Policy
  if_condition=$(echo $es_domain_policy | jq -r '.Statement[]' | grep Condition | wc -l)

  # Check if There is the "Condition" Section In the Policy
  principal=$(echo $es_domain_policy | jq -r '.Statement[].Principal[]')
  if [ $if_condition -eq 0 ] && [ "$principal" == "*" ]; then
    flag=1
    result_code=1
    result_msg="---> You are running Elasticsearch Service domain with publicly open policy !!!"
    result_detail=$result_detail" [$REGION]-ES-Domain-Name:$esdomain"
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
