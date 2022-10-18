module "vpc" {
  source                             = "./modules/vpc"
  vpc_name                           = "${var.env}-${var.project}-${var.vpc_name}"
  cidr                               = var.vpc_cidr
  azs                                = var.vpc_azs
  public_subnets                     = var.vpc_public_subnets
  private_subnets                    = var.vpc_private_subnets
  database_subnets                   = var.vpc_database_subnets
  create_database_subnet_group       = var.create_database_subnet_group
  create_database_subnet_route_table = var.create_database_subnet_route_table
  enable_nat_gateway                 = var.vpc_enable_nat_gateway
  one_nat_gateway_per_az             = var.vpc_one_nat_gateway_per_az
  single_nat_gateway                 = var.vpc_single_nat_gateway
  enable_dns_hostnames               = var.vpc_enable_dns_hostnames
  enable_dns_support                 = var.vpc_enable_dns_support

  tags_project = merge(local.tags, {
    Project = var.project
    ENV     = var.env
  })
}