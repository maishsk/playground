#!/bin/bash

## Create a IAM policy as follows and attach it to your instance
#
# {
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#             "Sid": "UpdateRecords",
#             "Effect": "Allow",
#             "Action": [
#                 "route53:GetHostedZone",
#                 "route53:ChangeResourceRecordSets",
#                 "route53:ListResourceRecordSets"
#             ],
#             "Resource": [
#                 "arn:aws:route53:::hostedzone/<__ZONE_ID__>"
#             ]
#         },
#         {
#             "Sid": "GetZones",
#             "Effect": "Allow",
#             "Action": "route53:ListHostedZones",
#             "Resource": "*"
#         }
#     ]
# }


## Define your variables
ZONE="<__ZONE_ID__>"
RECORD="<__RECORD_NAME__>"
DOMAIN="<__DOMAIN__>"
PUBLIC_IP=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
FILE="/home/ec2-user/dns_update.json"

## Build json file
rm -rf $FILE

cat <<EOF > $FILE
{
    "Comment": "Update record to reflect new IP address of home router",
    "Changes": [
        {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "$RECORD.$DOMAIN",
                "Type": "A",
                "TTL": 300,
                "ResourceRecords": [
                    {
                        "Value": "$PUBLIC_IP"
                    }
                ]
            }
        }
    ]
}
EOF

## Run the command
MAKE_CHANGE=`aws route53 change-resource-record-sets --hosted-zone-id $ZONE --change-batch file://$FILE`

## add this script to your crontab so that it runs at reboot
# @reboot /home/ec2-user/update_route53_record.sh
