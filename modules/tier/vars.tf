variable "vpc_id" {
	description = "The VPC ID to launch the tier architecture app into"
}

variable "map_public_ip_on_launch" {
	default = false
}

variable "cidr_block" {
	description = "The CIDR block of the tier subnet"
}

variable "name" {
	description = "Name to be used for tagging instances"
}

variable "user_data" {
	description = "User data to supply to the instance"
}

variable "route_table_id" {
	description = "id of route table to associate with the subnet"
}

variable "ami_id" {
	description = "id of route table to associate with the subnet"
}

variable "ingress" {
	type = "list"
}

variable "machine_count" {
  description = "The number of machines to create"
}