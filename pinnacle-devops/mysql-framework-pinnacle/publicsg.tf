# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "public" {
  name = "tf-${var.StackName}-public-sg"
  description = "Used in the terraform"
  vpc_id = "${aws_vpc.default.id}"

  tags = {
    key = "Name"
    value = "tf-${var.StackName}-public-sg"
  }

  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = "${split(",", var.remoteAccess)}"
  }

  # HTTP access from anywhere
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = "${split(",", var.remoteAccess)}"
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
