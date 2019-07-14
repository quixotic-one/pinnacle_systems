variable "key_name" {
  description = "Name of AWS key pair"
}

variable "StackName" {
  description = "StackName"
}

variable "customer" {}

variable "vpcCidr" {}

#variable "aws_vpc" {}

variable "region" {}

variable "remoteStateS3Bucket" {}

#variable "s3DevOpsBucket" {}

variable "environmentType" {}

variable "remoteAccess" {}
