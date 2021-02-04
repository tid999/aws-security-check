#/bin/bash

# result_code = 1,  Have route 53 alias points to non-existent resource 
# result_code = 0,  No route 53 alias points to non-existent resource 
# result_code = 11, Resource Dnsname

set +e

result=""
result_code=0
result_msg='No route 53 alias points to non-existent resource'

# printf "vvvvvvvvvv Execute Check - $(basename $0) Start: vvvvvvvvvv\n "

host_zones_ids=`aws route53 list-hosted-zones --query 'HostedZones[*].Id' --output text`
if [ ! -z "$host_zones_ids" ]; then
	for host_zone_id in $host_zones_ids
	do 
	    Dns_records=`aws route53 list-resource-record-sets --hosted-zone-id ${host_zone_id} --query "ResourceRecordSets[?AliasTarget].AliasTarget.DNSName" --output text`
	    for dns in $Dns_records
	    do 
	    array=(${dns//./ })
	    dns_region=${array[2]}
	    resource=${array[1]%-*}
	    echo  ${dns_region} ${resource}
	    ret=`aws elb describe-load-balancers --region ${dns_region} --load-balancer-name ${resource} >/dev/null 2>&1`
	    if [ $? -ne 0 ];then
		ret=`aws elbv2 describe-load-balancers --region ${dns_region} --names ${resource} >/dev/null 2>&1`
		if [ $? -ne 0 ];then
		    result[${#result[@]}]=${dns}
		fi
	    fi
	    done
	done 

	if [ "${#result[*]}" -gt "0" ];then
	  result_code=1
	  result_msg="---> You have route 53 alias points to non-existent resource"
	  echo $result_code','$result_msg >> /tmp/check_result.log
	fi

	for record in ${result[@]}
	do
	    echo '11,'DNS Name:$record >> /tmp/check_result.log
	    # echo -e "${record}"
	done
fi

printf "%s\n" "$result_msg"
# printf "^^^^^^^^^^ Execute Check - $(basename $0) Completed. ^^^^^^^^^^\n "
