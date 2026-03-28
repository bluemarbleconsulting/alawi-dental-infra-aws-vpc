# Zurich (eu-central-2) DR VPC
#
# Mirrors the Bahrain primary VPC topology. All resources use provider = aws.zurich.
# CIDR 10.1.0.0/16 is intentionally distinct from Bahrain (10.0.0.0/16).

data "aws_availability_zones" "zurich" {
  provider = aws.zurich
  state    = "available"
}

locals {
  zurich_selected_azs = slice(
    data.aws_availability_zones.zurich.names,
    0,
    min(var.desired_number_of_availability_zones, length(data.aws_availability_zones.zurich.names))
  )
}

# ------------------ VPC ------------------
#trivy:ignore:avd-aws-0178 # No VPC Flow Logs are necessary
resource "aws_vpc" "zurich" {
  provider                         = aws.zurich
  assign_generated_ipv6_cidr_block = true
  cidr_block                       = var.ipv4_zurich_cidr_block
  enable_dns_hostnames             = true
  enable_dns_support               = true

  tags = merge(
    var.default_tags,
    {
      Name = lower("${var.namespace}-zurich")
    },
  )
}

# trivy:ignore:AVD-AWS-0101 # We manage the default VPC as IaC, but do not use it
# trivy:ignore:AVD-AWS-0178 # No VPC Flow Logs are necessary
resource "aws_default_vpc" "zurich_default" {
  provider = aws.zurich

  tags = merge(
    var.default_tags,
    {
      Name = "Default-DoNotUse"
    },
  )
}

# ------------------ Subnets ------------------
resource "aws_subnet" "zurich_public" {
  provider                        = aws.zurich
  count                           = length(local.zurich_selected_azs)
  assign_ipv6_address_on_creation = true
  availability_zone               = local.zurich_selected_azs[count.index]
  cidr_block                      = cidrsubnet(aws_vpc.zurich.cidr_block, 8, count.index)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.zurich.ipv6_cidr_block, 8, count.index)
  map_public_ip_on_launch         = false
  vpc_id                          = aws_vpc.zurich.id

  tags = merge(
    var.default_tags,
    {
      Name = "${local.zurich_selected_azs[count.index % length(local.zurich_selected_azs)]}-zurich-public"
      Type = "public"
    }
  )

  lifecycle {
    ignore_changes = [cidr_block]
  }
}

resource "aws_subnet" "zurich_private" {
  provider                        = aws.zurich
  count                           = length(local.zurich_selected_azs)
  assign_ipv6_address_on_creation = true
  availability_zone               = local.zurich_selected_azs[count.index]
  cidr_block                      = cidrsubnet(aws_vpc.zurich.cidr_block, 8, count.index + length(local.zurich_selected_azs))
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.zurich.ipv6_cidr_block, 8, count.index + length(local.zurich_selected_azs))
  map_public_ip_on_launch         = false
  vpc_id                          = aws_vpc.zurich.id

  tags = merge(
    var.default_tags,
    {
      Name = "${local.zurich_selected_azs[count.index % length(local.zurich_selected_azs)]}-zurich-private"
      Type = "private"
    }
  )

  lifecycle {
    ignore_changes = [cidr_block]
  }
}

# ------------------ Internet Gateway ------------------
resource "aws_internet_gateway" "zurich" {
  provider = aws.zurich
  vpc_id   = aws_vpc.zurich.id

  tags = merge(
    var.default_tags,
    {
      Name = "zurich-igw"
    }
  )
}

# ------------------ Egress-Only Internet Gateway ------------------
resource "aws_egress_only_internet_gateway" "zurich" {
  provider = aws.zurich
  vpc_id   = aws_vpc.zurich.id

  tags = merge(
    var.default_tags,
    {
      Name = "zurich-eigw"
    }
  )
}

# ------------------ Route Tables ------------------
resource "aws_default_route_table" "zurich_default" {
  provider               = aws.zurich
  default_route_table_id = aws_vpc.zurich.default_route_table_id
  tags                   = var.default_tags
}

resource "aws_route_table" "zurich_public" {
  provider = aws.zurich
  vpc_id   = aws_vpc.zurich.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.zurich.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.zurich.id
  }

  route {
    cidr_block = aws_vpc.zurich.cidr_block
    gateway_id = "local"
  }

  route {
    ipv6_cidr_block = aws_vpc.zurich.ipv6_cidr_block
    gateway_id      = "local"
  }

  tags = merge(
    var.default_tags,
    {
      Name = "public-zurich-rt"
    }
  )
}

resource "aws_route_table" "zurich_private" {
  provider = aws.zurich
  vpc_id   = aws_vpc.zurich.id

  route {
    egress_only_gateway_id = aws_egress_only_internet_gateway.zurich.id
    ipv6_cidr_block        = "::/0"
  }

  route {
    cidr_block = aws_vpc.zurich.cidr_block
    gateway_id = "local"
  }

  route {
    ipv6_cidr_block = aws_vpc.zurich.ipv6_cidr_block
    gateway_id      = "local"
  }

  tags = merge(
    var.default_tags,
    {
      Name = "private-zurich-rt"
    }
  )

  lifecycle {
    ignore_changes = [route]
  }
}

# ------------------ Route Table Associations ------------------
resource "aws_route_table_association" "zurich_public_rt_association" {
  provider       = aws.zurich
  count          = length(aws_subnet.zurich_public)
  subnet_id      = aws_subnet.zurich_public[count.index].id
  route_table_id = aws_route_table.zurich_public.id
  depends_on     = [aws_internet_gateway.zurich]
}

resource "aws_route_table_association" "zurich_private_rt_association" {
  provider       = aws.zurich
  count          = length(aws_subnet.zurich_private)
  subnet_id      = aws_subnet.zurich_private[count.index].id
  route_table_id = aws_route_table.zurich_private.id
}

# ------------------ Default Security Group ------------------
resource "aws_default_security_group" "zurich_default" {
  provider = aws.zurich
  vpc_id   = aws_vpc.zurich.id
  tags     = var.default_tags
}
