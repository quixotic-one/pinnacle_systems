module "postgres-pinnacle" {
    source = "../postgres-framework-pinnacle"
    StackName = "${var.StackName}"
    customer = "${var.customer}"
    vpcCidr = "${var.vpcCidr}"
    remoteAccess = "${var.remoteAccess}"
    key_name = "${var.key_name}"
}
