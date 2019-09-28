#!/bin/bash -e

if [ ! -z "${debug}" ]; then
    set -x
    export TF_LOG=DEBUG
fi

echo
echo "##############################################################################"
echo
echo "                      Planning Pinnacle Jenkins Infrastructure"
echo
echo "##############################################################################"
echo

useIAM=$2
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

variablesFile="$1"
if [ -z "${variablesFile}" ]; then
    echo "Please specify a variables file in argument 1 for this script"
    exit 1
fi

if [ ! -e "${variablesFile}" ]; then
    echo "Could not locate variables file: ${variablesFile}"
    exit 1
fi

# Remove the existing .terraform directory if it exists
[ -d ./.terra* ] && rm -rf .terra*

while read line;
do
    export $(echo $line | tr -d "\"")
done < $1

if [ -z "${StackName}" ]; then
    echo "Please specify a StackName var in $1"
    exit 1
fi

if [ -z "${region}" ]; then
    echo "Please specify a region var in $1"
    exit 1
fi

if [ -z "${remoteStateS3Bucket}" ]; then
    echo "Please specify a remoteStateS3Bucket var in $1"
    exit 1
fi


tfStatesBucket="${remoteStateS3Bucket}-${region}"

echo "Getting dependent tf modules"
terraform get -update

echo bucket=\""${tfStatesBucket}"\" > backend.conf
echo key=\""${StackName}/tf-infrastructure.state"\" >> backend.conf
echo region=\""${region}"\" >> backend.conf

terraform init -backend-config=backend.conf
terraform plan -parallelism=1 -var-file="${variablesFile}" -out=plan.out
