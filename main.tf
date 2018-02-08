provider "aws" {
	region="eu-west-1"	
}

data "template_file" "app_init" {
	template = "${file("./scripts/app_user_data.sh")}"
}

resource "aws_instance" "app" {
	ami = "ami-5db8d324"
	instance_type = "t2.micro"
	user_data="${data.template_file.app_init.rendered}"
	subnet_id = "${aws_subnet.app.id}"
	security_groups = ["${aws_security_group.allow_all.id}"]
	tags {
		Name = "Jonathan-Terraform-App"
	}
}

resource "aws_vpc" "main" {
  cidr_block = "10.2.0.0/16"
  tags {
    Name = "VPC-Jonathan"
  }
}

resource "aws_subnet" "app" {
	vpc_id     = "${aws_vpc.main.id}"
	cidr_block = "10.2.0.0/24"
	map_public_ip_on_launch = true
	tags {
		Name = "jon-subnet-terraform-app"
  	}
}

resource "aws_security_group" "allow_all" {
        name        = "jon-sg-terraform-app"
        description = "Allow all inbound traffic"
		vpc_id     = "${aws_vpc.main.id}"
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
        Name = "Jon-Sg-Terraform-App"
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

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.app.id}"
  route_table_id = "${aws_route_table.public.id}"
}





