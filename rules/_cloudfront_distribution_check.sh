#/bin/bash

# result_code = 1,  Have cloudFront distribution points to non-existent origin
# result_code = 0,  No cloudFront distribution points to non-existent origin
# result_code = 11, CloudFront distribution ID

result=""
result_code=0
result_msg='No cloudFront distribution points to non-existent origin'
result_detail=""
flag=0

Ids=`aws cloudfront list-distributions --query "DistributionList.Items[*].Id" --output text`
for Id in $Ids
do
  if [ $Id != "None" ]; then
    records=`aws cloudfront get-distribution --id $Id --query "Distribution.DistributionConfig.Origins.Items[*].{id:Id,name:DomainName}" --output text`
    Type=`echo $records | awk -F ' ' '{print $1}' | awk -F '-' '{print $1}'`
    Dnsname=`echo $records | awk -F ' ' '{print $2}'`
    #echo $Type $Dnsname

    if [ "$Type" == "ELB" ];then
        array=(${Dnsname//./ })
        region=${array[1]}
        resource=${array[0]%-*}
        #echo $region $resource
        ret=`aws elb describe-load-balancers --region ${region} --load-balancer-name ${resource} >/dev/null 2>&1`
        if [ $? -ne 0 ];then
            ret=`aws elbv2 describe-load-balancers --region ${region} --names ${resource} >/dev/null 2>&1`
            if [ $? -ne 0 ];then
                result=$result" Distribution-Id:${Id}"
            fi
        fi
    elif [ "$Type" == "S3" ];then
        array=(${Dnsname//./ })
        resource=${array[0]}
        ret=`aws s3 ls ${resource} >/dev/null 2>&1`
        if [ $? -ne 0 ];then
            result=$result" Distribution-Id:${Id}"
        fi
    fi 
  fi
done

if [ ! -z ${result} ];then
  result_code=1
  result_msg="---> You have CloudFront distribution points to non-existent origin"
  echo $result_code','$result_msg >> /tmp/check_result.log
  # Print All Detailed Risky Resources
  for dd in $result
  do
      echo '11,'$dd >> /tmp/check_result.log
  done
fi

printf "%s\n" "$result_msg"
#printf "^^^^^^^^^^ Execute Check - $(basename $0) Completed. ^^^^^^^^^^\n "
