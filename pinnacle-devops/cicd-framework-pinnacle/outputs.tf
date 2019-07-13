output "JenkinsUI" {
  value = "${aws_elb.jenkins-elb.dns_name}"
}
