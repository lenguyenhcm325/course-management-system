data "aws_availability_zones" "available" {}

# random number that will be appended to iam policy and service account to avoid name clash
# see the initialize_cluster.sh for more information about the usage of this
resource "random_integer" "six_digit" {
  min = 100000
  max = 999999
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "cms-eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks_node_group_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "cms-eks-node-group-sg"
  description = "Security group for EKS worker nodes of the course management system project"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp", "ssh-tcp"]

  egress_rules = ["all-all"]
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "cms-eks-cluster"
  cluster_version = "1.28"

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_group_defaults = {
    capacity_type        = "ON_DEMAND"
    ami_type             = var.ami_type
    instance_types       = [var.instance_type]
    iam_role_name        = "cms-eks-worker-node-role"
    iam_role_description = "EKS worker node's role of the course management system project"
    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
    vpc_security_group_ids = [module.eks_node_group_sg.security_group_id]
  }

  eks_managed_node_groups = {
    default_node_group = {
      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
}

/*
This script performs the following tasks:
- Updates the kubeconfig to manage the cluster remotely
- Installs the AWS EBS CSI Driver using Helm
- Associates an IAM OIDC provider with the cluster
- Creates an IAM policy for the AWS Load Balancer Controller
- Creates an IAM service account for the AWS Load Balancer Controller
- Installs the AWS Load Balancer Controller using Helm
- Creates imagePullSecrets for ECR authentication
- Deploys the project (frontend, backend, and database) using Helm
- Waits for the Application Load Balancer to be created
- Updates Route 53 with a CNAME record pointing to the Load Balancer
*/
resource "null_resource" "initialize_cluster" {
  depends_on = [module.eks]
  provisioner "local-exec" {
    command = <<-EOT
    cd ${path.cwd} && \
    bash ./scripts/initialize_cluster.sh
  EOT
    environment = {
      ACCOUNT_ID    = var.account_id
      CLUSTER_NAME  = module.eks.cluster_name
      REGION        = var.region
      VPC_ID        = module.vpc.vpc_id
      RANDOM_NUMBER = random_integer.six_digit.id
    }
  }
}

# TODO: delete_cluster.sh when destroying the cluster
