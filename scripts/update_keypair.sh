#!/bin/bash

## Script will add a new keypair to AWS in all regions
## Required: awscli and jq
# $1 - filename

REGIONS=$(aws ec2 describe-regions | jq .Regions[].RegionName -r)
for region in $REGIONS
  do

    echo "Creating keypair in $region"
    aws ec2 import-key-pair --key-name $1 \
    --public-key-material fileb://~/.ssh/$1.pub --region $region
  done


# Get personal token password for Github from parameter store"
# GITHUB_TOKEN=$(aws ssm get-parameters --names /github/maishsk/personal_token --with-decryption --query "Parameters[0].Value" | tr -d '"')

#curl -u "maishsk:$GITHUB_TOKEN" \
#--data '{"title":"test-key","key":"ssh-rsa AAAA..."}' https://api.github.com/user/keys