################################################################################
# Publiс routes
################################################################################

resource "aws_route_table" "public" {
  count  = local.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = local.vpc_id
  tags   = merge(
    { "Name" = "${var.vpc_name}-${var.public_subnet_suffix}-rt" },
    var.tags_project,
  )
}

resource "aws_route" "public_internet_gateway" {
  count = local.create_vpc && var.create_igw && length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

################################################################################
# Private routes
# There are as many routing tables as the number of NAT gateways
################################################################################

resource "aws_route_table" "private" {
  count = local.create_vpc && local.max_subnet_length > 0 ? local.nat_gateway_count : 0

  vpc_id = local.vpc_id
  tags   = merge(
    {
      "Name" = var.single_nat_gateway ? "${var.vpc_name}-${var.private_subnet_suffix}" : format(
        "${var.vpc_name}-${var.private_subnet_suffix}-%s",
        "rt"
      )
    },
    var.tags_project,
  )
}

resource "aws_route" "private_nat_gateway" {
  count = local.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.private[*].id, count.index)
  destination_cidr_block = var.nat_gateway_destination_cidr_block
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

################################################################################
# Transit Gateway routes
################################################################################
resource "aws_route" "private_tgw_attach" {
  for_each = local._routes_private_tgw_map

  route_table_id         = each.value.rtb_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = each.value.transit_gateway_id
}

resource "aws_route" "database_tgw_attach" {
  for_each = local._routes_database_tgw_map

  route_table_id         = each.value.rtb_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = each.value.transit_gateway_id
}

resource "aws_route" "public_tgw_attach" {
  for_each = local._routes_public_tgw_map

  route_table_id         = each.value.rtb_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = each.value.transit_gateway_id
}

################################################################################
# Database routes
################################################################################

resource "aws_route_table" "database" {
  count  = local.create_vpc && var.create_database_subnet_route_table && length(var.database_subnets) > 0 ? var.single_nat_gateway || var.create_database_internet_gateway_route ? 1 : length(var.database_subnets) : 0

  vpc_id = local.vpc_id

  tags   = merge(
    {
      "Name" = var.single_nat_gateway || var.create_database_internet_gateway_route ? "${var.vpc_name}-${var.database_subnet_suffix}" : format(
        "${var.vpc_name}-${var.database_subnet_suffix}-%s","rt"
      )
    },
    var.tags_project,
  )
}

resource "aws_route" "database_internet_gateway" {
  count = local.create_vpc && var.create_igw && var.create_database_subnet_route_table && length(var.database_subnets) > 0 && var.create_database_internet_gateway_route && false == var.create_database_nat_gateway_route ? 1 : 0

  route_table_id         = aws_route_table.database[0].id
  destination_cidr_block = "10.0.0.0/16"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "database_nat_gateway" {
  count = local.create_vpc && var.create_database_subnet_route_table && length(var.database_subnets) > 0 && false == var.create_database_internet_gateway_route && var.create_database_nat_gateway_route && var.enable_nat_gateway ? var.single_nat_gateway ? 1 : length(var.database_subnets) : 0

  route_table_id         = element(aws_route_table.database[*].id, count.index)
  destination_cidr_block = "10.0.0.0/16"
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

################################################################################
# Peering Gateway routes
################################################################################
resource "aws_route" "private_pcx" {
  for_each = local._routes_private_pcx_map

  route_table_id                 = each.value.rtb_id
  destination_cidr_block         = each.value.destination_cidr_block
  vpc_peering_connection_id      = each.value.pcx_connection_id
}