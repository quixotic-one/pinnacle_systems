#!/bin/bash
aws_account_id=$(curl -s http://169.254.169.254/latest/meta-data/iam/info/ | jq -r '.InstanceProfileArn' | awk -F ':' '{print $5 }')
echo "Account ID used for AWS ECR is:  ${aws_account_id}"
echo "aws_account_id=${aws_account_id}" >> accountid.txt