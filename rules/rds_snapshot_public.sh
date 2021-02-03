#!/bin/bash

# result_code = 0, Miss, Safe
# result_code = 1, Hit, Danger

result_code=0
result_msg="No public RDS snapshot(s) found."
result_detail=""
flag=0

set +e
# printf "vvvvvvvvvv Execute Check - $(basename $0) Start: vvvvvvvvvv\n "

# for REGION in $(aws ec2 describe-regions --output text --query 'Regions[].[RegionName]') ; do 
    # echo "Check $REGION"; 
    #Check RDS
    for snap in $(aws rds describe-db-snapshots --output text --region $REGION --query 'DBSnapshots[*].DBSnapshotIdentifier'); do 
        check_result=`aws rds describe-db-snapshot-attributes --db-snapshot-identifier $snap --region $REGION --output text --query 'DBSnapshotAttributesResult.DBSnapshotAttributes[0].AttributeValues[*]'`
        if [ "$check_result" != "" ];then
	    flag=1
            result_code=1
	    result_msg="---> You have public RDS snapshot(s) !!!"
	    result_detail=$result_detail" [$REGION]-Snapshot-Id:$snap-is-Shared-to:$check_result"
        fi
    done
    #Check Aurora
    for snap in $(aws rds describe-db-cluster-snapshots --output text --region $REGION --query 'DBClusterSnapshots[*].DBClusterSnapshotIdentifier'); do
        check_result=`aws rds describe-db-cluster-snapshot-attributes --db-cluster-snapshot-identifier $snap --region $REGION --output text --query 'DBClusterSnapshotAttributesResult.DBClusterSnapshotAttributes[0].AttributeValues[*]'`
        if [ "$check_result" != "" ];then
	    flag=1
            result_code=1
	    result_msg="---> You have public RDS snapshot(s) !!!"
	    result_detail=$result_detail" [$REGION]-Snapshot-Id:$snap-is-Shared-to:$check_result"
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
