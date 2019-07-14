# Create 3 public subnet to launch our instances into
resource "aws_subnet" "public" {
  # Create three resources and use the count.index in then name. This will create
  # 3 subnets in the format aws_subnet.public.1.id
  count=3

  vpc_id = "${aws_vpc.default.id}"

  # Use the cidrsubnet interpoloation to add 8 bits to the vpccidr and then add a subnet
  # equal to the count index

  cidr_block              = "${cidrsubnet(aws_vpc.default.cidr_block, 8, count.index+1)}"

  map_public_ip_on_launch = true
  # Use the count.index to look up the AZ from the list

  availability_zone = "${element(split(",",var.availability_zones), count.index)}"

  tags = {
    Name = "${format("tf-${var.StackName}-public-%03d", count.index+1)}"
  }
}
