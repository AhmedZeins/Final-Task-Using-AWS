output "endpoint" {
  value = aws_eks_cluster.EKS.endpoint
}

# output "kubeconfig-certificate-authority-data" {
#   value = aws_eks_cluster.EKS.certificate_authority[0].data
# }