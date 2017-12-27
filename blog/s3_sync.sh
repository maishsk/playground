#!/bin/bash
##########################################################################
## Author:      Maish Saidel-Keesing
## Description: Script used to sync changes from an FTP into an S3 bucket
##              for the purpose of serving images from my blog from S3
## Version:     1.0
##########################################################################

## Activate virtualenv
source /home/centos/s3bucket/bin/activate

## Set variables
s3bucket="maishsk.com"
source_folder="/home/ftpblog/public/"

## Check if there is anything that changed
dry_run=`aws s3 sync --delete $source_folder s3://$s3bucket/ --dryrun`

if [[ $dry_run =~ dryrun ]]
then
  ## Print timestamp
  printf "$(date)\n----------------------------\n" >> /var/log/s3_sync.log

  ## Sync changes
  aws s3 sync --delete $source_folder $s3bucket >> /var/log/s3_sync.log
  printf "\n\n" >> /var/log/s3_sync.log
fi
