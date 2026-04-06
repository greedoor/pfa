data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  management_azs = slice(data.aws_availability_zones.available.names, 0, length(var.management_public_subnet_cidrs))
  soc_azs        = slice(data.aws_availability_zones.available.names, 0, length(var.soc_private_subnet_cidrs))
  workplace_azs  = slice(data.aws_availability_zones.available.names, 0, length(var.workplace_private_subnet_cidrs))
  nat_gateway_count = var.single_nat_gateway ? 1 : length(var.management_public_subnet_cidrs)
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_subnet" "management_public" {
  count                   = length(var.management_public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.management_public_subnet_cidrs[count.index]
  availability_zone       = local.management_azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                    = "${var.vpc_name}-management-public-${count.index + 1}"
    Tier                                    = "management"
    "kubernetes.io/role/elb"                = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "soc_private" {
  count             = length(var.soc_private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.soc_private_subnet_cidrs[count.index]
  availability_zone = local.soc_azs[count.index]

  tags = {
    Name                                      = "${var.vpc_name}-soc-private-${count.index + 1}"
    Tier                                      = "soc"
    "kubernetes.io/role/internal-elb"         = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "workplace_private" {
  count             = length(var.workplace_private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.workplace_private_subnet_cidrs[count.index]
  availability_zone = local.workplace_azs[count.index]

  tags = {
    Name = "${var.vpc_name}-workplace-private-${count.index + 1}"
    Tier = "workplace"
  }
}

resource "aws_eip" "nat" {
  count  = local.nat_gateway_count
  domain = "vpc"

  tags = {
    Name = "${var.vpc_name}-nat-eip-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count         = local.nat_gateway_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.management_public[count.index].id

  tags = {
    Name = "${var.vpc_name}-nat-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "management_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.vpc_name}-management-public-rt"
  }
}

resource "aws_route_table_association" "management_public" {
  count          = length(aws_subnet.management_public)
  subnet_id      = aws_subnet.management_public[count.index].id
  route_table_id = aws_route_table.management_public.id
}

resource "aws_route_table" "soc_private" {
  count  = length(var.soc_private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index % length(aws_nat_gateway.main)].id
  }

  tags = {
    Name = "${var.vpc_name}-soc-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "soc_private" {
  count          = length(aws_subnet.soc_private)
  subnet_id      = aws_subnet.soc_private[count.index].id
  route_table_id = aws_route_table.soc_private[count.index].id
}

resource "aws_route_table" "workplace_private" {
  count  = length(var.workplace_private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index % length(aws_nat_gateway.main)].id
  }

  tags = {
    Name = "${var.vpc_name}-workplace-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "workplace_private" {
  count          = length(aws_subnet.workplace_private)
  subnet_id      = aws_subnet.workplace_private[count.index].id
  route_table_id = aws_route_table.workplace_private[count.index].id
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = var.enable_vpc_flow_logs ? 1 : 0
  name              = "/aws/vpc/${var.vpc_name}/flow-logs"
  retention_in_days = var.flow_logs_retention_days
}

resource "aws_iam_role" "flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  name  = "${var.vpc_name}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  name  = "${var.vpc_name}-flow-logs-policy"
  role  = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_flow_log" "main" {
  count                    = var.enable_vpc_flow_logs ? 1 : 0
  iam_role_arn             = aws_iam_role.flow_logs[0].arn
  log_destination          = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  log_destination_type     = "cloud-watch-logs"
  traffic_type             = "ALL"
  vpc_id                   = aws_vpc.main.id
  max_aggregation_interval = 60

  depends_on = [aws_iam_role_policy.flow_logs]
}

resource "aws_security_group" "cluster" {
  name        = "${var.cluster_name}-shared-sg"
  description = "Shared security group for the SOC EKS cluster"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.cluster_name}-shared-sg"
  }
}

resource "aws_security_group_rule" "cluster_ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.cluster.id
}

resource "aws_security_group_rule" "cluster_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster.id
}
