#!/bin/bash

TOKEN="<insert_token"
GITHUB_URL="<insert_github_url>"
for i in `curl -s -H "Authorization: token $TOKEN"  https://$GITHUB_URL/api/v3/orgs/hercules/repos | jq .[].ssh_url -r`
do  
git clone $i
done

for dir in ./*/; do (cd "$dir" && mr register); done
