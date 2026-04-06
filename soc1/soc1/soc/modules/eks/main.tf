resource "aws_iam_role" "cluster" {
  count = var.cluster_role_arn == "" ? 1 : 0
  name  = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  count      = var.cluster_role_arn == "" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSVPCResourceController" {
  count      = var.cluster_role_arn == "" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role" "node" {
  count = var.node_role_arn == "" ? 1 : 0
  name  = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  count      = var.node_role_arn == "" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  count      = var.node_role_arn == "" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  count      = var.node_role_arn == "" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node[0].name
}

resource "aws_iam_role_policy_attachment" "node_AmazonSSMManagedInstanceCore" {
  count      = var.node_role_arn == "" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.node[0].name
}

locals {
  cluster_role_arn = var.cluster_role_arn != "" ? var.cluster_role_arn : aws_iam_role.cluster[0].arn
  node_role_arn    = var.node_role_arn != "" ? var.node_role_arn : aws_iam_role.node[0].arn
}

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = local.cluster_role_arn
  version  = var.kubernetes_version

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids              = concat(var.management_subnet_ids, var.soc_subnet_ids)
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    security_group_ids      = [var.security_group_id]
  }

  tags = {
    Name = var.cluster_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController
  ]
}

resource "aws_eks_node_group" "analysis" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-analysis"
  node_role_arn   = local.node_role_arn
  subnet_ids      = var.soc_subnet_ids
  version         = var.kubernetes_version

  scaling_config {
    desired_size = var.analysis_desired_nodes
    min_size     = var.analysis_min_nodes
    max_size     = var.analysis_max_nodes
  }

  update_config {
    max_unavailable = 1
  }

  instance_types = var.analysis_instance_types
  capacity_type  = "ON_DEMAND"
  disk_size      = var.analysis_disk_size

  labels = {
    workload = "analysis"
    tier     = "soc"
  }

  tags = {
    Name                                           = "${var.cluster_name}-analysis"
    "k8s.io/cluster-autoscaler/enabled"            = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.node_AmazonSSMManagedInstanceCore
  ]
}

resource "aws_eks_node_group" "storage" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-storage"
  node_role_arn   = local.node_role_arn
  subnet_ids      = var.soc_subnet_ids
  version         = var.kubernetes_version

  scaling_config {
    desired_size = var.storage_desired_nodes
    min_size     = var.storage_min_nodes
    max_size     = var.storage_max_nodes
  }

  update_config {
    max_unavailable = 1
  }

  instance_types = var.storage_instance_types
  capacity_type  = "ON_DEMAND"
  disk_size      = var.storage_disk_size

  labels = {
    workload = "storage"
    tier     = "soc"
  }

  taint {
    key    = "dedicated"
    value  = "storage"
    effect = "NO_SCHEDULE"
  }

  tags = {
    Name                                           = "${var.cluster_name}-storage"
    "k8s.io/cluster-autoscaler/enabled"            = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.node_AmazonSSMManagedInstanceCore
  ]
}

data "tls_certificate" "cluster" {
  count = var.create_oidc_provider ? 1 : 0
  url   = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  count           = var.create_oidc_provider ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = {
    Name = "${var.cluster_name}-oidc"
  }
}
