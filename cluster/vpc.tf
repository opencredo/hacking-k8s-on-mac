resource "aws_vpc" "vpc" {
  cidr_block           = "172.18.0.0/16"
  enable_dns_hostnames = true
  tags                 = local.tags
}

resource "aws_subnet" "subnets" {
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 1)
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  map_public_ip_on_launch = true
  tags                    = local.tags

  count = length(data.aws_availability_zones.azs.zone_ids)
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = local.tags
}

resource "aws_route_table" "table" {
  vpc_id = aws_vpc.vpc.id

  tags = local.tags
}

resource "aws_route_table_association" "association" {
  route_table_id = aws_route_table.table.id
  subnet_id      = aws_subnet.subnets.*.id[count.index]

  count = length(aws_subnet.subnets.*.id)
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}
