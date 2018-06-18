resource "aws_vpc" "${var.project_name}" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "${var.project_name}"
    }
}
