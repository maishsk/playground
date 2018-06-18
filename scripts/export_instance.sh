#!/bin/bash
##
## This script automates the process of exporting an AWS instance and
## importing it as an Glance image into OpenStack
##

progname=`basename "$0"`

##Check for parameters
if [ $# -ne 5 ]
then
    echo "Not all arguments supplied were supplied. Please provide all the arguments to the script."
    echo "Usage: $progname <instance-id> <bucket-name> <aws_access_key_id> <aws_secret_access_key> <default_region>"
    echo "For example: $progname i-09ec9d3gd731eead5 my-bucket AKIXVSDESIIDIH5OBXZA s4Zss3tF0fFF9FOOISIISwHrWVs3VG us-west-1"
    echo "Script now Exiting....."
    exit
fi

INSTANCE_ID=$1
BUCKET_NAME=$2
AWS_ACCESS_KEY_ID=$3
AWS_SECRET_ACCESS_KEY=$4
AWS_DEFAULT_REGION=$5

## Get Volume and PublicIP information from instance
VOL_ID=$(aws ec2 describe-instances --instance-id $INSTANCE_ID --query 'Reservations[].Instances[].BlockDeviceMappings[].Ebs[].VolumeId' | grep vol | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e 's/\"//g')

PUBLIC_IP=$(aws ec2 describe-instances --instance-id $INSTANCE_ID | grep PublicIpAddress | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e 's/\"//g' -e 's/PublicIpAddress: //g' -e 's/,//g')

## Get volume size and type
VOL_TYPE=$(aws ec2 describe-volumes --volume-id $VOL_ID | grep VolumeType |  sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e 's/\"//g' -e 's/VolumeType: //g' -e 's/,//g')

VOL_SIZE=$(aws ec2 describe-volumes --volume-id $VOL_ID | grep Size | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e 's/\"//g' -e 's/Size: //g')

VOL_AZ=$(aws ec2 describe-volumes --volume-id $VOL_ID | grep AvailabilityZone| sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e 's/\"//g' -e 's/AvailabilityZone: //g' -e 's/,//g')

## Create new Volume
NEW_VOL=$(aws ec2 create-volume --size $VOL_SIZE --region us-west-1 --availability-zone $VOL_AZ --volume-type $VOL_TYPE | grep VolumeId | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e 's/\"//g' -e 's/VolumeId: //g' -e 's/,//g')

## Attach Volume to instance
aws ec2 attach-volume --volume-id $NEW_VOL --instance-id $INSTANCE_ID --device /dev/xvdf

## Partition Disk
ssh ec2-user@$PUBLIC_IP '(echo n; echo p; echo 1; echo ""; echo ""; echo w) | sudo fdisk /dev/xvdf'

## Format disk and Mount
ssh ec2-user@$PUBLIC_IP 'sudo mkfs.ext4 /dev/xvdf1; sudo mkdir /tmp/disk; sudo mount /dev/xvdf1 /tmp/disk'

## Copy disk to Image file
ssh ec2-user@$PUBLIC_IP 'sudo dd if=/dev/xvda of=/tmp/disk/disk.img'

## Add AWS credentials to remote instance
ssh ec2-user@$PUBLIC_IP "aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID; aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY; aws configure set default.region $AWS_DEFAULT_REGION"

## Copy image to S3 *FROM* instance
ssh ec2-user@$PUBLIC_IP 'aws s3 cp /tmp/disk/disk.img s3://my-b1-bucket/'

## unmount disk and remove from instance
ssh ec2-user@$PUBLIC_IP 'sudo umount /tmp/disk'
aws ec2 detach-volume --volume-id $NEW_VOL
aws ec2 delete-volume --volume-id $NEW_VOL

## Copy image from S3 *TO* instance
mkdir /tmp/ami
aws s3 cp s3://my-b1-bucket/disk.img /tmp/ami/

## Add image to glance
glance image-create --disk-format raw --container-format bare --name myami --file /tmp/ami/disk.img --progress
