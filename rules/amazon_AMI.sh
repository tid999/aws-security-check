#!/bin/bash

# result_code = 0, Miss, Safe
# result_code = 1, Hit, Danger
# result_code = 11, Danger Detail
# check if "ImageOwnerAlias" is tagged to the image

set +e
# printf "vvvvvvvvvv Execute Check - $(basename $0) Start: vvvvvvvvvv\n "

Image_Owner_Id=""
result_code=0
result_msg="No instances running public AMIs that are not owned by Amazon."
result_detail=""
flag=0
flag_image=""

Account_ID=`aws sts get-caller-identity --query 'Account' --output text`
image_ids=$(aws ec2 describe-instances --query Reservations[].Instances[].ImageId --region $REGION --output text)

for imageid in ${image_ids}; do
  flag_imageid="imageid"

  # Check if the AMI is ownered by Amazon
  check_AMI_owner=$(aws ec2 describe-images --image-ids ${imageid} --query Images[].ImageOwnerAlias --region $REGION --output text 2>/dev/null | wc -l)
  if [ $?  -gt 1 ]; then continue; fi
  if [ "$check_AMI_owner" -eq "0" ]; then
    Image_Owner_Id=$(aws ec2 describe-images --image-ids $imageid --query Images[].OwnerId --output text 2>/dev/null )
    if [ $?  -gt 1 ]; then continue; fi
    if [ ! -z $Image_Owner_Id ] && [ $Image_Owner_Id != $Account_ID ]; then
        flag=1
        result_code=1
        result_msg="---> You are running instance with public AMIs that are not owned by Amazon."
        result_detail=$result_detail" [$REGION]-Image-Id:$imageid"
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
