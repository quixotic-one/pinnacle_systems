output "CICDUI" {
  value = "${aws_elb.cicd-elb.dns_name}"
}
