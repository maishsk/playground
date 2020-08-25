#!/bin/bash

## Script will delete a keypair in all regions
## Required: awscli and jq
# $1 - filename

REGIONS=$(aws ec2 describe-regions | jq .Regions[].RegionName -r)
for region in $REGIONS
  do
    echo "Deleting keypair in $region"
    aws ec2 delete-key-pair --key-name $1 --region $region
  done
