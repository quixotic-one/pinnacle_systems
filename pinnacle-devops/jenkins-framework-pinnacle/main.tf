# Specify the provider and access details
# Uncomment below if you are planning on using AWS Profiles
provider "aws" {
  region = "${var.aws_region}"
}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "${StackName}-tf-states-${var.aws_region}"
    key            = "global/s3/terraform.tfstate"
    region         = "us-west-2"
  }
}

resource "null_resource" "copy_scripts" {
  provisioner "local-exec" {
    command = "aws s3 cp ${path.module}/scripts s3://${var.customer}-devops-${var.aws_region}/ --recursive"
  }

}


/*
resource "tfStatesBucket" "tf-states" {
  bucket = "${StackName}-tf-states-${var.aws_region}"
  acl = "private"
  versioning {
    enabled = true
  }

  tags = {
    Name = "${StackName}-tf-states-${var.aws_region}"
  }

}
*/

data "template_file" "userdata" {
  template = "${file("${path.module}/userdata.tpl")}"
  depends_on = ["null_resource.copy_scripts"]

  vars = {
    Template_StackName = "${var.StackName}"
    customer = "${var.customer}"
    region = "${var.aws_region}"
    s3DevOpsBucket = "${var.customer}-devops-${var.aws_region}"
  }
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  tags = {
    Name = "tf-${var.StackName}-vpc"
  }
  cidr_block = "${var.vpcCidr}"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_elb" "jenkins-elb" {
  name = "tf-${var.StackName}-jenkins-elb"

  # The same availability zone as our instances
  subnets = aws_subnet.public.*.id
  security_groups = aws_security_group.public.*.id

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 8080
    lb_protocol = "http"
  }

  listener {
    instance_port = 4506
    instance_protocol = "tcp"
    lb_port = 4506
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 4505
    instance_protocol = "tcp"
    lb_port = 4505
    lb_protocol = "tcp"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:8080"
    interval = 30
  }

}

resource "aws_autoscaling_group" "jenkins-asg" {
  vpc_zone_identifier = aws_subnet.public.*.id
  name = "tf-${var.StackName}-asg-${aws_launch_configuration.jenkins-lc.id}"
  max_size = "${var.asg_max}"
  min_size = "${var.asg_min}"
  desired_capacity = "${var.asg_desired}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.jenkins-lc.name}"
  load_balancers = ["${aws_elb.jenkins-elb.name}"]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    value = "tf-${var.StackName}-jenkins-asg"
    propagate_at_launch = "true"
  }
}

resource "aws_launch_configuration" "jenkins-lc" {
  name_prefix = "tf-${var.StackName}-jenkins-lc"
  image_id = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.jenkins_pinnacle.name}"
  # Security group
  security_groups = ["${aws_security_group.private.id}","${aws_security_group.public.id}"]
  user_data = "${data.template_file.userdata.rendered}"
  key_name = "${var.key_name}"

  lifecycle {
    create_before_destroy = true
  }

  ebs_block_device {
    device_name = "/dev/xvdf"
    volume_type = "standard"
    volume_size = "80"
  }
}
