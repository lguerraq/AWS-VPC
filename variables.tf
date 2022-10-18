################################################################
#             Global Variables
################################################################
variable "env" {}
variable "project" {}
variable "primary_region" {}
variable "profile" {
  description = "Profile for providers"
  type        = string
  default     = "CloudGuru"
}
#################################################################
#           Vpc Variables
#################################################################
variable "vpc_name" {}
variable "vpc_cidr" {}
variable "vpc_azs" {}
variable "vpc_public_subnets" {}
variable "vpc_private_subnets" {}
variable "vpc_database_subnets" {}
variable "vpc_enable_nat_gateway" {}
variable "vpc_one_nat_gateway_per_az" {}
variable "vpc_single_nat_gateway" {}
variable "vpc_enable_dns_hostnames" {}
variable "vpc_enable_dns_support" {}
variable "create_database_subnet_group" {}
variable "create_database_subnet_route_table" {}