###############################################################
#           Global Variables
###############################################################
env              = "prd"
project          = "AWSPeru"
primary_region   = "us-east-1"
#################################################################
#           Vpc Variables
#################################################################
vpc_name                            = "networking-vpc"
vpc_cidr                            = "192.168.0.0/20"
vpc_azs                             = ["us-east-1a", "us-east-1b"]
vpc_public_subnets                  = ["192.168.0.0/22", "192.168.4.0/22"]
vpc_private_subnets                 = ["192.168.8.0/23", "192.168.10.0/23"]
vpc_database_subnets                = ["192.168.12.0/23", "192.168.14.0/23"]
vpc_enable_nat_gateway              = true
vpc_one_nat_gateway_per_az          = true
vpc_single_nat_gateway              = true
vpc_enable_dns_hostnames            = true
vpc_enable_dns_support              = true
create_database_subnet_group        = true
create_database_subnet_route_table  = true