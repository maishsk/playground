#!/bin/bash

# Requires - cfcli https://blog.droidzone.in/2017/04/20/using-cloudflare-command-line-interface/

. $HOME/.bashrc

NAMESERVER='bonnie.ns.cloudflare.com'
RECORD='jabawoki-ext.maishsk.com'
CURRENT_IP=`dig +short $RECORD @$NAMESERVER`
EXTERNAL_IP=`curl -s ifconfig.co`

if [[ $EXTERNAL_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  if [[ $EXTERNAL_IP != $CURRENT_IP ]]; then
    printf "$(date)\n\n"
    /usr/local/bin/cfcli -t A edit $RECORD $EXTERNAL_IP
  else
    echo "$(date): IP has not changed"
  fi  
else
  echo "$(date): Not a valid IP - Exiting"
  exit 1
fi
