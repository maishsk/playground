#!/bin/bash

# Requires - cfcli https://blog.droidzone.in/2017/04/20/using-cloudflare-command-line-interface/

EXTERNAL_IP=`curl -s ifconfig.co`
RECORD='coder'

cfcli -t A edit $RECORD $EXTERNAL_IP
