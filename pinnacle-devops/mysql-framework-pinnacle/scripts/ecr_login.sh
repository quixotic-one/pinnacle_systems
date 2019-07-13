#!/bin/bash

#login to AWS ECR

loginCmd=$(aws ecr get-login --region us-west-2 | sed 's/-e none //')

$loginCmd
