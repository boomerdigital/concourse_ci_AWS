provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"

}

data "aws_availability_zones" "available" {}


#VPC

resource "aws_vpc" "vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}


# Internet gateway

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
}


# Route tables

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
        cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  }
  tags {
  Name = "public"
  }
}

resource "aws_default_route_table" "private" {
  default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"
  tags {
    Name = "private"
  }
}


# Subnet public

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "public"
  }
}


# Subnet private

resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = false
  availability_zone = "${data.aws_availability_zones.available.names[2]}"

  tags {
    Name = "private1"
  }
}


# Subnet DB

resource "aws_subnet" "rds1" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "rds1"
  }
}

resource "aws_subnet" "rds2" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.4.0/24"
  map_public_ip_on_launch = false
  availability_zone = "${data.aws_availability_zones.available.names[2]}"

  tags {
    Name = "rds2"
  }
}

resource "aws_subnet" "rds3" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.5.0/24"
  map_public_ip_on_launch = false
  availability_zone = "${data.aws_availability_zones.available.names[3]}"

  tags {
    Name = "rds3"
  }
}


# Subnet Associations

resource "aws_route_table_association" "public_assoc" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_db_subnet_group" "rds_subnetgroup" {
  name = "rds_subnetgroup"
  subnet_ids = ["${aws_subnet.rds1.id}", "${aws_subnet.rds2.id}", "${aws_subnet.rds3.id}" ]

  tags {
    Name = "rds_sng"
  }
}


# Public security group

resource "aws_security_group" "public" {
  name = "sg_public"
  description = "Port 80 open with SSH from local host"
  vpc_id = "${aws_vpc.vpc.id}"

  # SSH

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.localip_cidr}"]
  }


  # HTTP

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Private security group

resource "aws_security_group" "private" {
  name        = "sg_private"
  description = "Used for private instances"
  vpc_id      = "${aws_vpc.vpc.id}"
  

# Access from other security groups

  ingress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["10.1.0.0/16"]
  }

  egress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
  }
}


#RDS Security Group

resource "aws_security_group" "RDS" {
  name= "sg_rds"
  description = "Used for DB instances"
  vpc_id      = "${aws_vpc.vpc.id}"


# SQL access from public/private security group
  
  ingress {
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = ["${aws_security_group.public.id}", "${aws_security_group.private.id}"]
  }
}

# DB postgreSQL

resource "aws_db_instance" "db" {
  allocated_storage	    = 10
  engine		    = "postgres"
  engine_version	    = "9.6.1"
  instance_class	    = "${var.db_instance_class}"
  name			    = "${var.dbname}"
  username		    = "${var.dbuser}"
  password		    = "${var.dbpassword}"
  db_subnet_group_name      = "${aws_db_subnet_group.rds_subnetgroup.name}"
  vpc_security_group_ids    = ["${aws_security_group.RDS.id}"]
  skip_final_snapshot       = false
  copy_tags_to_snapshot     = true
  final_snapshot_identifier = "${var.final_snapshot_id}"
  publicly_accessible       = true
}

# Key pair

resource "aws_key_pair" "auth" {
  key_name  ="${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}


# Concourse server

resource "aws_instance" "concourse_web" {
  private_ip    = "10.1.1.10"
  instance_type = "${var.web_instance_type}"
  ami           = "${var.web_ami}"
  tags {
    Name = "concourse_web"
  }

  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.public.id}"]
  subnet_id = "${aws_subnet.public.id}"
}


# Worker server

resource "aws_instance" "concourse_worker" {
  private_ip    = "10.1.1.20"
  instance_type = "${var.worker_instance_type}"
  ami           = "${var.worker_ami}"
  tags {
    Name = "concourse_worker_1"
  }

  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.public.id}"]
  subnet_id = "${aws_subnet.public.id}"
}



