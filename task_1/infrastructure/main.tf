terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    region       = "us-east-1"
    profile      = "terraform"
    bucket       = "onboarding-project-100"
    key          = "task_1/terraform.tfstate"
    use_lockfile = true
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "terraform"
}

module "vpc" {
  source = "./modules/network"

  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnet_cidrs = ["10.0.2.0/24", "10.0.3.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]

  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "routing" {
  source = "./modules/routing"

  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.vpc.internet_gateway_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids

  enable_nat = false
}

module "bastion_security" {
  source = "./modules/security"

  name        = "bastion-sg"
  description = "Bastion security group"
  vpc_id      = module.vpc.vpc_id

  rules = {
    ssh = {
      description        = "ssh conection rule"
      traffic_type       = "ingress"
      source_cidr_blocks = [var.my_ip]
      port_range_start   = 22
      port_range_end     = 22
      protocol_name      = "tcp"
    }
  }
}

module "asg_security" {
  source = "./modules/security"

  name        = "scaling-sg"
  description = "Auto scalling group security rules"
  vpc_id      = module.vpc.vpc_id

  rules = {
    ssh = {
      description        = "ssh connection from bastion"
      traffic_type       = "ingress"
      source_security_group_id = module.bastion_security.security_group_id
      port_range_start   = 22
      port_range_end     = 22
      protocol_name      = "tcp"
    }
  }
}

module "rds_security" {
  source = "./modules/security"
  name = "database-sg"
  description = "Database instances security group"
  vpc_id = module.vpc.vpc_id

  rules = {
    ssh = {
      description = "ssh connection from bastion"
      traffic_type = "ingress"
      source_security_group_id = module.bastion_security.security_group_id
      port_range_start = 22
      port_range_end = 22
      protocol_name = "tcp"
    }
  }
}