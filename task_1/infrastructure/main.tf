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
}

module "routing" {
  source = "./modules/routing"

  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.vpc.internet_gateway_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids

  enable_nat = false
}