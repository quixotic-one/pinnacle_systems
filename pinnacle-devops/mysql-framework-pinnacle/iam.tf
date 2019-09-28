resource "aws_iam_policy" "mysql_pinnacle" {
  name = "mysql-${var.StackName}-policy"
  path = "/"
  description = "mysql-${var.StackName}-policy"
  policy = "${data.template_file.iam.rendered}"
}

data "template_file" "iam" {
  template = "${file("${path.module}/iam.tpl")}"
  vars = {
    AWS_ACCOUNT_ID="${data.aws_caller_identity.current.account_id}"
  }
}

resource "aws_iam_policy_attachment" "mysql_pinnacle" {
  name = "mysql-${var.StackName}-attach"
  roles = ["${aws_iam_role.mysql_pinnacle.name}"]
  policy_arn = "${aws_iam_policy.mysql_pinnacle.arn}"
}

resource "aws_iam_instance_profile" "mysql_pinnacle" {
  name = "mysql-${var.StackName}-instance"
  role = "${aws_iam_role.mysql_pinnacle.name}"
}

resource "aws_iam_role" "mysql_pinnacle" {
  name = "mysql-${var.StackName}-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
