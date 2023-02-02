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


module "application-tier" {
  name = "walter-app"
  source = "./modules/application-tier"
  vpc_id = "${aws_vpc.walter-application-deployment.id}"
  route_table_id = "${aws_route_table.walter-rt.id}"
  cidr_block = "10.4.0.0/24"
  user_data = templatefile("./scripts/app_user_data.sh", {})
  ami_id = "ami-046173580183b4d6f"
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