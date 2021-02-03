#!/bin/bash

# result_code = 1, Have paravirtual Instance
# result_code = 0, NO paravirtual Instance
# result_code = 11, Instance Type Detail

# printf "vvvvvvvvvv Execute Check - $(basename $0) Start: vvvvvvvvvv\n "

result_code=0
result_msg='No paravirtual Instance'

check_result=$(aws ec2 describe-instances --query 'Reservations[*].Instances[?VirtualizationType==`paravirtual`].InstanceId' --region $REGION --output text)

if [[ -n "$check_result"  ]];then
  result_code=1
  result_msg='---> You have paravirtual Instance'
  echo $result_code','$result_msg >> /tmp/check_result.log
fi

for type in $check_result
do
  echo '11,'[$REGION]-Instance-Id:$type >> /tmp/check_result.log
done

printf "%s\n" "$result_msg"
# printf "^^^^^^^^^^ Execute Check - $(basename $0) Completed. ^^^^^^^^^^\n "
