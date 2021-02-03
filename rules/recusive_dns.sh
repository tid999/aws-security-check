#!/bin/bash

# result_code = 1, Hit, Danger
# result_code = 0, Miss, Safe

result_code=0
result_msg="No recursive DNS server accessible from Internet"
result_detail=""
flag=0

# printf "vvvvvvvvvv Execute Check - $(basename $0) Start: vvvvvvvvvv\n "

# Get all public IP address under the account
ips="$(aws ec2 describe-network-interfaces --query NetworkInterfaces[].Association[].PublicIp --region $REGION --output text)"
ips=$ips" EOF"

for ip in $ips:
do
  if [ $ip != 'EOF:' ]; then
    # Scan if port 53 is accessible
    cmd_result="$(timeout --signal=9 2 host www.cnn.com. ${ip} 2>/dev/null)"
    excute_result=$?
    if [ $excute_result -eq 0 ]; then	# Port 53 is accessible
	check_result="$(echo $cmd_result | egrep 'no servers could be reached|Host www.cnn.com not found' | wc -l )"
        if [ "$check_result" -eq "0" ]; then
	    flag=1
	    result_code=1
	    result_msg="---> There is recursive DNS server accessible from Internet"
	    result_detail=$result_detail" [$REGION]-${ip}"
	fi
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
