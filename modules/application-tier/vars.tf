variable "vpc_id" {
  description = "The VPC ID in AWS"
}

variable "name" {
  description = "Name to be used for the Tags"
}

variable "route_table_id" {
  description = "ID of Route Table"
}

variable "cidr_block" {
  description = "VPC IP"
}

variable "user_data" {
  description = "Script SH file"
}

variable "ami_id" {
  description = "ID of the AMI"
}

variable "map_public_ip_on_launch" {
    default = false
  description = "Assigning public IP on launch"
}

variable "ingress" {
    type = list
  description = "Collection of rules that allow connections to reach the endpoints defined by a backend"
}