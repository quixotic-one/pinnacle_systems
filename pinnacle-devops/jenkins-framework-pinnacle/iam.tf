resource "aws_iam_policy" "jenkins" {
  name = "jenkins-${var.StackName}_policy"
  path = "/"
  description = "jenkins-${var.StackName}_policy"
  policy = "${data.template_file.iam.rendered}"
}

data "template_file" "iam" {
  template = "${file("${path.module}/iam.tpl")}"
  vars = {
    AWS_ACCOUNT_ID="${data.aws_caller_identity.current.account_id}"
  }
}

resource "aws_iam_policy_attachment" "jenkins-attach" {
  name = "jenkins-${var.StackName}_attach"
  roles = ["${aws_iam_role.jenkins.name}"]
  policy_arn = "${aws_iam_policy.jenkins.arn}"
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-${var.StackName}-profile"
  role = "${aws_iam_role.jenkins.name}"
}

resource "aws_iam_role" "jenkins" {
  name = "jenkins-${var.StackName}"
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
