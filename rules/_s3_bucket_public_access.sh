#!/bin/bash

# result_code = 0, Miss, Safe
# result_code = 1, Hit, Danger
# result_code = 11, Danger Detail
set +e
# printf "vvvvvvvvvv Execute Check - $(basename $0) Start: vvvvvvvvvv\n "

buckets=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text | tr '\t' '\n')

result_code=0
result_msg="No World-readable or World-Writable S3 Buckets."
result_detail=""
flag=0
flag_bucket=""

for bucket in ${buckets}; do
  flag_bucket="$bucket"

  # Check bucket public access block
  check_result_block=$(aws s3api get-public-access-block --bucket $bucket --query 'PublicAccessBlockConfiguration' --output text | tr '\t' '\n' | grep -v 'True' | wc -l)
  # Check bucket ACL world access
  check_result_acl=$(aws s3api get-bucket-acl --bucket mytestjack --query "Grants[].Grantee[].URI" --output text | tr '\t' '\n'|egrep 'AllUsers|AuthenticatedUsers' | wc -l)

  if [ $check_result_block -gt 0 ] || [ $check_result_acl -gt 0 ]; then
    flag=1
    result_code=1
    result_msg="---> One or more S3 buckets World-readable or World-Writable."
    result_detail=$result_detail" BucketName:$bucket"
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
