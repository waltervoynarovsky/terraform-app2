provider "aws"{
    region="us-west-1"
}

# Create our VPC

resource "aws_vpc" "walter-application-deployment" {
  cidr_block = "10.4.0.0/16"

  tags = {
    Name = "walter-application-deployment-vpc"
  }
}


resource "aws_internet_gateway" "walter-ig" {
    vpc_id = "${aws_vpc.walter-application-deployment.id}"
  tags = {
    Name = "walter-ig"
  }
}

resource "aws_route_table" "walter-rt" {
    vpc_id = "${aws_vpc.walter-application-deployment.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.walter-ig.id}"
    }
}


module "db-tier" {
  name = "walter-database"
  source = "./modules/db-tier"
  vpc_id = "${aws_vpc.walter-application-deployment.id}"
  route_table_id = "${aws_vpc.walter-application-deployment.main_route_table_id}"
  cidr_block = "10.4.1.0/24"
  user_data = templatefile("./scripts/db_user_data.sh", {})
  ami_id = "ami-0d17099f9a1843ab6"
  map_public_ip_on_launch = false

  ingress = [{
    from_port = 27017
    to_port = 27017
    protocol = "tcp"
    cidr_blocks = "${module.application-tier.subnet_cidr_block}"
  }]
}


module "application-tier" {
  name = "walter-app"
  source = "./modules/application-tier"
  vpc_id = "${aws_vpc.walter-application-deployment.id}"
  route_table_id = "${aws_route_table.walter-rt.id}"
  cidr_block = "10.4.0.0/24"
  user_data = templatefile("./scripts/app_user_data.sh", {mongodb_ip = module.db-tier.private_ip})
  ami_id = "ami-0d303287a96a6816c"
  map_public_ip_on_launch = true

  ingress = [{
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = "0.0.0.0/0"
  },
  {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = "18.117.8.240/32"
  }, 
  {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = "92.8.160.94/32"
}]
}