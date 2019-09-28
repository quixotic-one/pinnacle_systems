variable "aws_region" {
  description = "The AWS region to create things in."
  default = "us-west-2"
}

# Amazon AMI
variable "aws_amis" {
  type = "map"
  default = {
    us-west-2 = "ami-068a5e9c87370be8b"
  }
}

variable "availability_zones" {
  default = "us-west-2a,us-west-2b,us-west-2c"
  description = "List of availability zones, use AWS CLI to find your "
}

variable "key_name" {
  description = "Name of AWS key pair"
}

variable "instance_type" {
  default = "t2.micro"
  description = "AWS instance type"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default = "1"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default = "1"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default = "1"
}

variable "StackName" {
  description = "StackName"
}

variable "aws_iam_role" {
  description = "mysql_pinnacle_role"
  default = "mysql_pinnacle"
}

variable "aws_iam_instance_profile" {
  description = "mysql_pinnacle_instance"
  default = "mysql_pinnacle"
}

variable "aws_iam_policy_attachment" {
  description = "mysql_pinnacle_policy"
  default = "mysql_pinnacle"
}

variable "customer" {}

variable "vpcCidr" {}

variable "remoteAccess" {}
