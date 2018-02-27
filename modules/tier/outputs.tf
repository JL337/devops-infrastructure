output "subnet_cidr_block" {
	value = "${var.cidr_block}"
}

output "private_ip" {
    value = "${aws_instance.app.*.private_ip[0]}"
}

output "app_id" {
    value = "${aws_instance.app.*.id}"
}

output "sub_id" {
    value = "${aws_subnet.app.id}"
}

output "sec_id" {
    value = "${aws_security_group.allow_all.id}"
}