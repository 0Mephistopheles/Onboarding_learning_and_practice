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

  enable_nat = true
}

module "bastion_security" {
  source = "./modules/security"

  name        = "bastion-sg"
  description = "Bastion security group"
  vpc_id      = module.vpc.vpc_id

  rules = {
    ssh = {
      description        = "ssh connection rule"
      traffic_type       = "ingress"
      source_cidr_blocks = [var.my_ip]
      port_range_start   = 22
      port_range_end     = 22
      protocol_name      = "tcp"
    }

    outbound = {
      description        = "allow bastion outbound traffic"
      traffic_type       = "egress"
      source_cidr_blocks = ["0.0.0.0/0"]
      port_range_start   = 0
      port_range_end     = 0
      protocol_name      = "-1"
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
      description              = "ssh connection from bastion"
      traffic_type             = "ingress"
      source_security_group_id = module.bastion_security.security_group_id
      port_range_start         = 22
      port_range_end           = 22
      protocol_name            = "tcp"
    }

    outbound = {
      description        = "allow bastion outbound traffic"
      traffic_type       = "egress"
      source_cidr_blocks = ["0.0.0.0/0"]
      port_range_start   = 0
      port_range_end     = 0
      protocol_name      = "-1"
    }
  }
}

module "database_security" {
  source      = "./modules/security"
  name        = "database-sg"
  description = "Database instances security group"
  vpc_id      = module.vpc.vpc_id

  rules = {
    postgres = {
      description              = "postgres conection from asg"
      traffic_type             = "ingress"
      source_security_group_id = module.asg_security.security_group_id
      port_range_start         = 5432
      port_range_end           = 5432
      protocol_name            = "tcp"
    }

    outbound = {
      description        = "allow bastion outbound traffic"
      traffic_type       = "egress"
      source_cidr_blocks = ["0.0.0.0/0"]
      port_range_start   = 0
      port_range_end     = 0
      protocol_name      = "-1"
    }
  }
}

module "bastion_instance" {
  source = "./modules/ec2_instance"

  subnet_id                   = module.vpc.public_subnet_ids[0]
  security_group_ids          = [module.bastion_security.security_group_id]
  associate_public_ip_address = true
  instance_key                = "dev_key"

  instance_system_type = {
    ami_image_type = "ami-0bdc7d025135d7b49"
    instance_type  = "t3.micro"
  }

  instance_volume = {
    volume_type     = "gp3"
    volume_size     = 8
    deletion_policy = true
  }
}

module "scaling_group" {
  source = "./modules/asg"

  launch_template_name = "ai-processors"
  group_name           = "ai-processors"

  instance_system_type = {
    ami_image_type = "ami-0bdc7d025135d7b49"
    instance_type  = "t3.small"
  }
  instance_key = "dev_key"

  instance_volume = {
    volume_type           = "gp3"
    volume_size           = 16
    delete_on_termination = true
  }
  security_group_ids = [module.asg_security.security_group_id]
  subnet_ids         = module.vpc.private_subnet_ids
  device_root        = "/dev/xvda"

  group_capacity = 1
  group_min_size = 1
  group_max_size = 2
  enable_scaling = true

  check_type          = "EC2"
  check_period        = 180
  scaling_type        = "TargetTrackingScaling"
  cpu_threshold       = 80
  scaling_policy_name = "ai-cpu-demand"
}

data "aws_secretsmanager_secret" "rds_credentials" {
  name = "RDS_credentials_task_1"
}

data "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = data.aws_secretsmanager_secret.rds_credentials.id
}

locals {
  rds_credentials = jsondecode(data.aws_secretsmanager_secret_version.rds_credentials.secret_string)
}

module "database" {
  source = "./modules/rds"

  private_subnet_ids  = module.vpc.private_subnet_ids
  vpc_security_groups = [module.database_security.security_group_id]

  db_type = {
    db_engine  = "postgres"
    db_class   = "db.t4g.micro"
    db_version = "16.4"
  }

  db_storage = {
    storage_size = 20
    storage_type = "gp3"
  }

  db_port       = 5432
  is_multi_az   = true
  public_access = false
  db_user = {
    db_name       = "thinking_tank"
    user_name     = local.rds_credentials.user_name
    user_password = local.rds_credentials.password
  }
  skip_snapshot = true
}