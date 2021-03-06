#!/bin/bash

# result_code = 0, Miss, Safe
# result_code = 1, Hit, Danger

result_code=0
result_msg="No public EBS snapshot(s) found."
result_detail=""
flag=0

set +e
# printf "vvvvvvvvvv Execute Check - $(basename $0) Start: vvvvvvvvvv\n "

# for REGION in $(aws ec2 describe-regions --output text --query 'Regions[].[RegionName]') ; do
    result_code=0;
    # echo "Check $REGION"; 
    for snap in $(aws ec2 describe-snapshots --owner self --output text --region $REGION --query 'Snapshots[*].SnapshotId'); do 
        check_result=`aws ec2 describe-snapshot-attribute --snapshot-id $snap --region $REGION --output text --attribute createVolumePermission --query 'CreateVolumePermissions[0].Group'`
        #if [ "$check_result" = "all" ];then
        if [ "$check_result" != "None" ];then
	    flag=1
            result_code=1
	    result_msg="---> You have public EBS snapshot(s) !!!"
	    result_detail=$result_detail" [$REGION]-Snapshot-Id:$snap"
        fi
    done
# done

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
