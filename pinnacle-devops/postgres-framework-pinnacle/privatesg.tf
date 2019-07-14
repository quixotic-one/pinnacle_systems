# Our default private security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "private" {
  name = "tf-${var.StackName}-private-sg"
  description = "Used in the terraform"
  vpc_id = "${aws_vpc.default.id}"

  tags = {
    key = "Name"
    value = "tf-${var.StackName}-private-sg"
  }

  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = ["${aws_security_group.public.id}"]
  }

  # HTTP access from anywhere
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = ["${aws_security_group.public.id}"]
  }

  # salt minion
  ingress {
    from_port = 4505
    to_port = 4505
    protocol = "tcp"
    security_groups = ["${aws_security_group.public.id}"]
  }

  # salt minion
  ingress {
    from_port = 4506
    to_port = 4506
    protocol = "tcp"
    security_groups = ["${aws_security_group.public.id}"]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
