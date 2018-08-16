#!/bin/bash
# start-jumpbox

# get public IP from coder
HOST_NAME='<__hostname__>'
JUMPBOX_IP=`nslookup $HOST_NAME | tail -n 2 | head -n1 | awk '{print $2}'`

## Update security group
SECGROUP_ID='<__SECGROUP_ID__>'
REGION='us-east-2'

## Modify Security Group Rules
# Get previous rule
OLD_RULE=`aws ec2 describe-security-groups --group-ids $SECGROUP_ID --region $REGION | jq -r .SecurityGroups[0].IpPermissions[0].IpRanges[0].CidrIp`

# Remove previous Rule
aws ec2 revoke-security-group-ingress --group-id $SECGROUP_ID --protocol tcp --port 22 --cidr $OLD_RULE --region $REGION

# Add New Rule
aws ec2 authorize-security-group-ingress --group-id $SECGROUP_ID --protocol tcp --port 22 --cidr $JUMPBOX_IP/32 --region $REGION
