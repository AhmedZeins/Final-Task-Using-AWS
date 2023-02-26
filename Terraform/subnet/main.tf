resource "aws_subnet" "lab3-subnet" {

    cidr_block = var.subnet_cidr_block
    vpc_id = var.sub_vpc_id
    availability_zone = var.sub_availability_zone
    
    tags = {
        Name = var.subnet_name
        "kubernetes.io/cluster/EKS-Cluster" = "shared"
        "kubernetes.io/role/elb"    = 1
    }
}