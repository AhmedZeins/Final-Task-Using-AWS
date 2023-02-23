# Create a node group for the EKS cluster
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name = var.cluster_name

  node_group_name = var.node_group_name

  node_role_arn = var.node_role_arn
  #aws_iam_role.eks_node_group.arn
  # Use only private subnets for the node group  -----> edit this one

  subnet_ids = var.subnet_ids

  # Valid values: ON_DEMAND, SPOT
  capacity_type = "ON_DEMAND"
  instance_types = ["t2.medium"]
  # Disk size in GiB for worker nodes
  disk_size = 20
  force_update_version = false

  scaling_config {
    desired_size = 1 
    max_size = 1
    min_size = 1
  }

  labels = {
    role = "nodes-general"
  }

  version = "1.24"

  depends_on = [
    aws_iam_role.eks_node_group.eks_node_group,
    aws_iam_role.eks_node_group.eks_node_group_cni,
    aws_iam_role.eks_node_group.eks_node_group_ReadOnly,
  ]

  

}

# Create an IAM role for the node group
resource "aws_iam_role" "eks_node_group" {
  name = "eks-node-group-role"

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

# Attach policies to the node group IAM role
resource "aws_iam_role_policy_attachment" "eks_node_group" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group_ReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}