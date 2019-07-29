#!/bin/bash
set -x
SHELL=/bin/bash
BASH_ENV=~/.bashrc


## Activate virtualenv
source /home/centos/s3bucket/bin/activate

source /home/centos/.s3syncrc

## Set variables
s3bucket="maishsk.com"
source_folder="/home/ftpblog/public/"

## Check if there is anything that changed
dry_run=`aws-vault exec s3_ftp -- aws s3 sync --delete $source_folder s3://$s3bucket/ --dryrun`

if [[ $dry_run =~ dryrun ]]
then
  ## Print timestamp
  printf "$(date)\n----------------------------\n" >> /var/log/s3_sync.log

  ## Sync changes
  aws-vault exec s3_ftp -- aws s3 sync --delete $source_folder s3://$s3bucket/ >> /var/log/s3_sync.log
  printf "\n\n" >> /var/log/s3_sync.log
fi
