resource "aws_iam_policy" "cicd" {
  name = "cicd-${var.StackName}_policy"
  path = "/"
  description = "cicd-${var.StackName}_policy"
  policy = "${data.template_file.iam.rendered}"
}

data "template_file" "iam" {
  template = "${file("${path.module}/iam.tpl")}"
  vars = {
    AWS_ACCOUNT_ID="${data.aws_caller_identity.current.account_id}"
  }
}

resource "aws_iam_policy_attachment" "cicd-attach" {
  name = "cicd-${var.StackName}_attach"
  roles = ["${aws_iam_role.cicd.name}"]
  policy_arn = "${aws_iam_policy.cicd.arn}"
}

resource "aws_iam_instance_profile" "cicd_profile" {
  name = "cicd-${var.StackName}-profile"
  role = "${aws_iam_role.cicd.name}"
}

resource "aws_iam_role" "cicd" {
  name = "cicd-${var.StackName}"
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
