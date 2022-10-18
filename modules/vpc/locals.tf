locals {
  max_subnet_length = max(
    length(var.private_subnets),
    length(var.database_subnets),
  )
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length

  # Use `local.vpc_id` to give a hint to Terraform that subnets should be deleted before secondary CIDR blocks can be free!
  vpc_id = try(aws_vpc_ipv4_cidr_block_association.this[0].vpc_id, aws_vpc.this[0].id, "")

  create_vpc = var.create_vpc

  _routes_private_pcx = flatten([
    for k in try(var.peering_gateway_routes,[]) : [
      for v in try(aws_route_table.private.*,{}) : {
        "${v.id}_${k.pcx_connection_id}_${k.destination_cidr_block}" = {
          rtb_id                        = v.id
          destination_cidr_block        = k.destination_cidr_block
          pcx_connection_id             = k.pcx_connection_id
          route_table_databse_enabled   = try(k.route_table_database,false)
          route_table_private_enabled   = try(k.route_table_private,false)
          route_table_public_enabled    = try(k.route_table_public,false)
        }
      }
    ]
    if try(k.route_table_private,false)
  ])

  # transform the list into a map
  _routes_private_pcx_map = { 
    for item in local._routes_private_pcx: keys(item)[0] => values(item)[0]
  }

  _routes_private_tgw = flatten([
    for k in try(var.transit_gateway_routes,[]) : [
      for v in try(aws_route_table.private.*,{}) : {
        "${v.id}_${k.transit_gateway_id}_${k.destination_cidr_block}" = {
          rtb_id                        = v.id
          destination_cidr_block        = k.destination_cidr_block
          transit_gateway_id            = k.transit_gateway_id
          route_table_databse_enabled   = try(k.route_table_database,false)
          route_table_private_enabled   = try(k.route_table_private,false)
          route_table_public_enabled    = try(k.route_table_public,false)
        }
      }
    ]
    if try(k.route_table_private,false)
  ])

  # transform the list into a map
  _routes_private_tgw_map = { 
    for item in local._routes_private_tgw: keys(item)[0] => values(item)[0]
  }

  _routes_database_tgw = flatten([
    for k in try(var.transit_gateway_routes,[]) : [
      for v in try(aws_route_table.database.*,{}) : {
        "${v.id}_${k.transit_gateway_id}_${k.destination_cidr_block}" = {
          rtb_id                        = v.id
          destination_cidr_block        = k.destination_cidr_block
          transit_gateway_id            = k.transit_gateway_id
          route_table_databse_enabled   = try(k.route_table_database,false)
          route_table_private_enabled   = try(k.route_table_private,false)
          route_table_public_enabled    = try(k.route_table_public,false)
        }
      }
    ]
    if try(k.route_table_database,false)
  ])

  # transform the list into a map
  _routes_database_tgw_map = { 
    for item in local._routes_database_tgw: keys(item)[0] => values(item)[0]
  }

  _routes_public_tgw = flatten([
    for k in try(var.transit_gateway_routes,[]) : [
      for v in try(aws_route_table.public.*,{}) : {
        "${v.id}_${k.transit_gateway_id}_${k.destination_cidr_block}" = {
          rtb_id                        = v.id
          destination_cidr_block        = k.destination_cidr_block
          transit_gateway_id            = k.transit_gateway_id
          route_table_databse_enabled   = try(k.route_table_database,false)
          route_table_private_enabled   = try(k.route_table_private,false)
          route_table_public_enabled    = try(k.route_table_public,false)
        }
      }
    ]
    if try(k.route_table_public,false)
  ])

  # transform the list into a map
  _routes_public_tgw_map = { 
    for item in local._routes_public_tgw: keys(item)[0] => values(item)[0]
  }
}