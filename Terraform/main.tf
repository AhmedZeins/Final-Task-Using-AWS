module "lab3-vpc" {
  source = "./vpc"
  vpc_cider = "10.0.0.0/16"
  vpc_name = "lab3-vpc"
}

module "public_subnet_1st" {
  source = "./subnet"
  subnet_cidr_block = "10.0.0.0/24"
  sub_availability_zone = "us-east-1a"
  subnet_name = "public_subnet_1st"
  sub_vpc_id = module.lab3-vpc.vpc_id
}

module "public_subnet_2nd" {
  source = "./subnet"
  subnet_cidr_block = "10.0.2.0/24"
  sub_availability_zone = "us-east-1b"
  subnet_name = "public_subnet_2nd"
  sub_vpc_id = module.lab3-vpc.vpc_id
}

module "private_subnet_1st" {
  source = "./subnet"
  subnet_cidr_block = "10.0.1.0/24"
  sub_availability_zone = "us-east-1a"
  subnet_name = "private_subnet_1st"
  sub_vpc_id = module.lab3-vpc.vpc_id
}

module "private_subnet_2nd" {
  source = "./subnet"
  subnet_cidr_block = "10.0.3.0/24"
  sub_availability_zone = "us-east-1b"
  subnet_name = "private_subnet_2nd"
  sub_vpc_id = module.lab3-vpc.vpc_id
}

module "internet_gateway" {
  source = "./igw"
  igw_name = "my_internet_gateway"
  igw_vpc_id = module.lab3-vpc.vpc_id
}

module "nat_gateway" {
  source = "./nat gateway"
  nat_name = "lab3-gateway"
  nat_subnet_id = module.public_subnet_1st.lab3-subnet_id
  nat_depends_on = module.internet_gateway
}

module "security_group" {
  source = "./securitygroup"
  securitygroup_name = "security_group"
  securitygroup_description = "security_group"
  securitygroup_vpc_id = module.lab3-vpc.vpc_id
  securitygroup_from_port_in = 22
  securitygroup_to_port_in = 80
  securitygroup_protocol_in = "tcp"
  securitygroup_cider = ["0.0.0.0/0"]
  securitygroup_from_port_eg = 0
  securitygroup_to_port_eg = 0
  securitygroup_protocol_eg = "-1"
}


module "public_route_table" {
  source = "./routetable"
  table_name = "lab3-public_table"
  table_vpc_id = module.lab3-vpc.vpc_id
  table_destination_cidr_block = "0.0.0.0/0"
  table_gateway_id = module.internet_gateway.lab3-igw
  table_subnet_id = { id1 = module.public_subnet_2nd.lab3-subnet_id, id2 = module.public_subnet_1st.lab3-subnet_id }
  depends_on = [
    module.public_subnet_1st.subnet_id,
    module.private_subnet_2nd.subnet_id
  ]
}

module "private_route_table" {
  source = "./routetable"
  table_name = "private_table"
  table_vpc_id = module.lab3-vpc.vpc_id
  table_destination_cidr_block = "0.0.0.0/0"
  table_gateway_id = module.nat_gateway.nat_gw_id
  table_subnet_id = {id1 = module.private_subnet_2nd.lab3-subnet_id, id2 = module.private_subnet_1st.lab3-subnet_id }
}


module "ec2_public" {
  source = "./ec2"
  ec2_ami_id = "ami-06878d265978313ca"
  ec2_instance_type = "t2.micro"
  ec2_name = "ec2-public"
  ec2_public_ip = true
  ec2_subnet_ip = module.public_subnet_1st.lab3-subnet_id
  ec2_security_gr = [ module.security_group.securitygroup_id ]
 
}


module "EKS" {
  soursource = "./EKS"
  eks-name = "EKScluster"
  subnet_id = 
    
}

module "node-group" {
  source = "./node-group"
  node_role_arns = aws_iam_role.eks_node_group.arn
  cluster_name = "EKScluster"
  node_group_name = "eks-node-cluster"
  subnet_id = 
}
