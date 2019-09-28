resource "aws_iam_policy" "jenkins_pinnacle" {
  name = "jenkins-${var.StackName}-policy"
  path = "/"
  description = "jenkins-${var.StackName}-policy"
  policy = "${file("${path.module}/iam.tpl")}"
}

resource "aws_iam_policy_attachment" "jenkins_pinnacle" {
  name = "jenkins-${var.StackName}-attach"
  roles = ["${aws_iam_role.jenkins_pinnacle.name}"]
  policy_arn = "${aws_iam_policy.jenkins_pinnacle.arn}"
}

resource "aws_iam_instance_profile" "jenkins_pinnacle" {
  name = "jenkins-${var.StackName}-profile"
  role = "${aws_iam_role.jenkins_pinnacle.name}"
}

resource "aws_iam_role" "jenkins_pinnacle" {
  name = "jenkins-${var.StackName}-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com",
          "ecs.amazonaws.com",
          "ecs-tasks.amazonaws.com",
          "application-autoscaling.amazonaws.com"
      ]}
    }
  ]
}
EOF
}
