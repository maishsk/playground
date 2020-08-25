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
