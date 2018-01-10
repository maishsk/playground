#!/bin/bash

## Script will get all AZ info from AWS through awscli
## Required: awscli and jq

AZINFO=$(for i in $(aws ec2 describe-regions | jq .Regions[].RegionName | tr -d '"')
  do
    aws ec2 describe-availability-zones --region $i | jq .AvailabilityZones[].ZoneName | tr -d '"'
  done | sort)

echo ""  > availability_zone_info.md

#This is necessary because of markdown on Github
for i in $AZINFO
  do
    echo $i "  " >> availability_zone_info.md
  done
