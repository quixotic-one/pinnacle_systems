resource "aws_iam_policy" "postgres" {
  name = "postgres-${var.StackName}_policy"
  path = "/"
  description = "postgres-${var.StackName}_policy"
  policy = "${data.template_file.iam.rendered}"
}

data "template_file" "iam" {
  template = "${file("${path.module}/iam.tpl")}"
  vars = {
    AWS_ACCOUNT_ID="${data.aws_caller_identity.current.account_id}"
  }
}

resource "aws_iam_policy_attachment" "postgres-attach" {
  name = "postgres-${var.StackName}_attach"
  roles = ["${aws_iam_role.postgres.name}"]
  policy_arn = "${aws_iam_policy.postgres.arn}"
}

resource "aws_iam_instance_profile" "postgres_profile" {
  name = "postgres-${var.StackName}-profile"
  role = "${aws_iam_role.postgres.name}"
}

resource "aws_iam_role" "postgres" {
  name = "postgres-${var.StackName}"
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
