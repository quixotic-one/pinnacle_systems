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

#variable "aws_region" {
#  default = "us-west-2"
#}
#
variable "remoteStateS3Bucket" {}

#variable "s3DevOpsBucket" {}

variable "aws_iam_role" {}

variable "environmentType" {}

variable "remoteAccess" {}
