resource "aws_iam_policy" "mysql" {
  name = "mysql-${var.StackName}_policy"
  path = "/"
  description = "mysql-${var.StackName}_policy"
  policy = "${data.template_file.iam.rendered}"
}

data "template_file" "iam" {
  template = "${file("${path.module}/iam.tpl")}"
  vars = {
    AWS_ACCOUNT_ID="${data.aws_caller_identity.current.account_id}"
  }
}

resource "aws_iam_policy_attachment" "mysql-attach" {
  name = "mysql-${var.StackName}_attach"
  roles = ["${aws_iam_role.mysql.name}"]
  policy_arn = "${aws_iam_policy.mysql.arn}"
}

resource "aws_iam_instance_profile" "mysql_profile" {
  name = "mysql-${var.StackName}-profile"
  role = "${aws_iam_role.mysql.name}"
}

resource "aws_iam_role" "mysql" {
  name = "mysql-${var.StackName}"
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
