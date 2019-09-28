module "jenkins-pinnacle" {
    source = "../jenkins-framework-pinnacle"
    StackName = "${var.StackName}"
    customer = "${var.customer}"
    vpcCidr = "${var.vpcCidr}"
    remoteAccess = "${var.remoteAccess}"
    key_name = "${var.key_name}"
    aws_iam_role = "${var.aws_iam_role}"
}


#    aws_iam_role = "${var.aws_iam_role}"
