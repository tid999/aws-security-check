#!/bin/bash

# result_code = 1, Hit, Danger
# result_code = 0, Miss, Safe

port=443
result_code=0
result_msg="No external endpoint uses deprecated SSL cipher suites or protocols"
result_detail=""
flag=0

# printf "vvvvvvvvvv Execute Check - $(basename $0) Start: vvvvvvvvvv\n "

# Get all public IP address under the account
ips="$(aws ec2 describe-network-interfaces --query NetworkInterfaces[].Association[].PublicIp --region $REGION --output text)"
ips=$ips" EOF"

for ip in $ips:
do
  if [ $ip != 'EOF:' ]; then
    # Check if the port is open
    result_port_open=`echo quit | timeout --signal=9 2 telnet $ip $port 2>/dev/null | grep Connected | wc -l`
    if [ $result_port_open -eq 1 ]; then
      # Check if the deprecated SSL cipher suites used
      check_result="$(openssl s_client -tls1_2 -cipher 'NULL,EXPORT,LOW,DES' -connect $ip:443 2>/dev/null | grep 'no peer certificate available' | wc -l)"
      if [ $check_result -eq 0 ];then
	  flag=1
          result_code=1
          result_msg="There are external endpoints use deprecated SSL cipher suites or protocols"
          result_detail=$result_detail" [$REGION]-$ip"
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
