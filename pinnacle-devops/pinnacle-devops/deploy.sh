#!/bin/bash -e

if [ ! -z "${debug}" ]; then
    set -x
    export TF_LOG=DEBUG
fi

echo
echo "##############################################################################"
echo
echo "                       Deploying Pinnacle Jenkins Infrastructure"
echo
echo "##############################################################################"
echo

useIAM=$1
if [ -z "${useIAM}" ];
then
    echo "Using Local AWS Credentials for Remote State"
    aws_profile=pinnacle
    aws_access_key_id=$(aws configure get aws_access_key_id --profile ${aws_profile})
    aws_secret_access_key=$(aws configure get aws_secret_access_key --profile ${aws_profile})
    export AWS_ACCESS_KEY_ID=${aws_access_key_id}
    export AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}
else
    echo "Using IAM Credentials for Remote State"
fi

terraform apply -parallelism=1 plan.out
