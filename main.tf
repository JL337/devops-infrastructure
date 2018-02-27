provider "aws" {
	region="eu-west-1"	
}

data "template_file" "app_init" {
	template = "${file("./scripts/app_user_data.sh")}"
  vars {
    db_ip = "${module.db-tier.private_ip}"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.2.0.0/16"
  enable_dns_hostnames = true 
  tags {
    Name = "VPC-Jonathan"
  }
}

resource "aws_internet_gateway" "gw" {
	vpc_id     = "${aws_vpc.main.id}"
	tags {
	    Name = "Jonathan-Gateway"
	}
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "Jonathan-Public"
  }
}

module "app-tier" {
  name="Jonathan-App"
  source="./modules/tier"
  vpc_id="${aws_vpc.main.id}"
  route_table_id="${aws_route_table.public.id}"
  cidr_block="10.2.0.0/24"
  user_data="${data.template_file.app_init.rendered}"
  ami_id = "ami-5db8d324"
  map_public_ip_on_launch = true
  machine_count = 2

  ingress = [{
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "0.0.0.0/0"
  }]
}

module "db-tier" {
  name="Jonathan-DB"
  source="./modules/tier"
  vpc_id="${aws_vpc.main.id}"
  route_table_id="${aws_vpc.main.main_route_table_id}"
  cidr_block="10.2.1.0/24"
  user_data=""
  ami_id = "ami-8c80ebf5"
  machine_count = 1

  ingress = [{
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = "${module.app-tier.subnet_cidr_block}"
  }]
}

# Create a new load balancer
resource "aws_elb" "lb" {
  name               = "jon-terraform-elb"
  # availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }

  instances                   = ["${module.app-tier.app_id}"]
  security_groups             = ["${module.app-tier.sec_id}"]
  subnets                     = ["${module.app-tier.sub_id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "jon-terraform-elb"
  }
}
