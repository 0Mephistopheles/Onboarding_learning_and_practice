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

module "network" {
  source = "./modules/network"


  virtual_private_clouds = {
    vpc_a = {
      vpc_cidr             = "10.0.0.0/16"
      enable_dns_hostnames = true
      enable_dns_support   = true

      vpc_subnets = {
        subnet_1 = {
          type              = "public"
          subnet_cidr       = "10.0.0.0/24"
          availability_zone = "us-east-1a"
        }
        subnet_2 = {
          type              = "public"
          subnet_cidr       = "10.0.1.0/24"
          availability_zone = "us-east-1b"
        }
        subnet_3 = {
          type              = "private"
          subnet_cidr       = "10.0.2.0/24"
          availability_zone = "us-east-1a"
        }
        subnet_4 = {
          type              = "private"
          subnet_cidr       = "10.0.3.0/24"
          availability_zone = "us-east-1b"
        }
      }

      routing_configuration = {
        destination_cidr_block = "0.0.0.0/0"
        enable_nat             = true
        nat_location_name      = "subnet_1"
      }
    }
  }
}

module "vpc_a_security" {
  source = "./modules/security"
  vpc_id = module.network.vpc_ids["vpc_a"]

  security_groups = {
    bastion_security = {
      group_description = "Bastion security rules"

      rules = {
        ssh = {
          description        = "ssh connection rule"
          traffic_type       = "ingress"
          source_cidr_blocks = [var.my_ip_1, var.my_ip_2]
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

    asg_security = {
      group_description = "Auto scalling group security rules"

      rules = {
        ssh = {
          description              = "ssh connection from bastion"
          traffic_type             = "ingress"
          source_security_group_id = "bastion_security"
          port_range_start         = 22
          port_range_end           = 22
          protocol_name            = "tcp"
        }

        llama_api = {
          description              = "Open WebUI access to TinyLlama API"
          traffic_type             = "ingress"
          source_security_group_id = "internal_alb_security"
          port_range_start         = 8080
          port_range_end           = 8080
          protocol_name            = "tcp"
        }

        node_exporter = {
          description              = "Node Exporter metrics from internal ALB"
          traffic_type             = "ingress"
          source_security_group_id = "web_server_security"
          port_range_start         = 9100
          port_range_end           = 9100
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

    database_security = {
      group_description = "Database instances security group"

      rules = {
        postgres = {
          description              = "postgres conection from asg"
          traffic_type             = "ingress"
          source_security_group_id = "asg_security"
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

    web_server_security = {
      group_description = "Openwebui web server security rules"

      rules = {
        http = {
          description        = "external access to openwebui"
          traffic_type       = "ingress"
          source_cidr_blocks = ["0.0.0.0/0"]
          port_range_start   = 8080
          port_range_end     = 8080
          protocol_name      = "tcp"
        }

        metrics = {
          description        = "metrics access"
          traffic_type       = "ingress"
          source_cidr_blocks = [var.my_ip_1, var.my_ip_2]
          port_range_start   = 9090
          port_range_end     = 9090
          protocol_name      = "tcp"
        }

        dashboard = {
          description        = "dashboard access"
          traffic_type       = "ingress"
          source_cidr_blocks = [var.my_ip_1, var.my_ip_2]
          port_range_start   = 3000
          port_range_end     = 3000
          protocol_name      = "tcp"
        }

        ssh = {
          description              = "ssh connection from bastion"
          traffic_type             = "ingress"
          source_security_group_id = "bastion_security"
          port_range_start         = 22
          port_range_end           = 22
          protocol_name            = "tcp"
        }

        outbound = {
          description        = "allow web server outbound traffic"
          traffic_type       = "egress"
          source_cidr_blocks = ["0.0.0.0/0"]
          port_range_start   = 0
          port_range_end     = 0
          protocol_name      = "-1"
        }
      }
    }

    internal_alb_security = {
      group_description = "Internal alb security rules"
      rules = {
        http = {
          description              = "allow traffic from web server"
          traffic_type             = "ingress"
          source_security_group_id = "web_server_security"
          port_range_start         = 8080
          port_range_end           = 8080
          protocol_name            = "tcp"
        }

        metrics = {
          description              = "Prometheus access to Node Exporter targets"
          traffic_type             = "ingress"
          source_security_group_id = "web_server_security"
          port_range_start         = 9100
          port_range_end           = 9100
          protocol_name            = "tcp"
        }

        outbound = {
          description              = "allow outbound traffic from load balancer"
          traffic_type             = "egress"
          source_security_group_id = "asg_security"
          port_range_start         = 0
          port_range_end           = 0
          protocol_name            = "-1"
        }
      }
    }
  }
}

module "load_balancers" {
  source = "./modules/load_balancer"
  load_balancers = {
    internal_alb = {
      balancer_name = "llama-balancer"
      balancer_type = "application"

      security_group_ids = [module.vpc_a_security.security_group_id["internal_alb_security"]]
      subnet_ids         = [module.network.private_subnet_ids["vpc_a.subnet_3"], module.network.private_subnet_ids["vpc_a.subnet_4"]]
      is_internal        = true
      protect_deletion   = false
      timeout_limit      = 60
    }
  }

  target_groups = {
    scaling_group = {
      group_name     = "scaling-group"
      group_port     = 8080
      group_protocol = "HTTP"
      target_type    = "instance"
      vpc_id         = module.network.vpc_ids["vpc_a"]
      check_enabled  = true
      check_path     = "/health"
      check_protocol = "HTTP"
    }

    node_exporter = {
      group_name     = "node-exporter"
      group_port     = 9100
      group_protocol = "HTTP"
      target_type    = "instance"
      vpc_id         = module.network.vpc_ids["vpc_a"]
      check_enabled  = true
      check_path     = "/metrics"
      check_protocol = "HTTP"
    }
  }

  target_listeners = {
    llama_listener = {
      load_balancer_key   = "internal_alb"
      target_group_key    = "scaling_group"
      listener_port       = 8080
      listener_protocol   = "HTTP"
      default_action_type = "forward"
    }

    metrics_listener = {
      load_balancer_key   = "internal_alb"
      target_group_key    = "node_exporter"
      listener_port       = 9100
      listener_protocol   = "HTTP"
      default_action_type = "forward"
    }
  }
}

module "bastion_instance" {
  source = "./modules/ec2_instance"

  subnet_id                   = module.network.public_subnet_ids["vpc_a.subnet_1"]
  security_group_ids          = [module.vpc_a_security.security_group_id["bastion_security"]]
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

module "web_server" {
  source = "./modules/ec2_instance"

  subnet_id                   = module.network.public_subnet_ids["vpc_a.subnet_2"]
  security_group_ids          = [module.vpc_a_security.security_group_id["web_server_security"]]
  associate_public_ip_address = true
  instance_key                = "dev_key"

  instance_system_type = {
    ami_image_type = "ami-0bdc7d025135d7b49"
    instance_type  = "t3.small"
  }

  instance_volume = {
    volume_type     = "gp3"
    volume_size     = 16
    deletion_policy = true
  }
}

module "scaling_group" {
  source = "./modules/asg"

  launch_template_name = "ai-processors"
  group_name           = "ai-processors"

  instance_system_type = {
    ami_image_type = "ami-0bdc7d025135d7b49"
    instance_type  = "t3.micro"
  }
  instance_key = "dev_key"

  instance_volume = {
    volume_type           = "gp3"
    volume_size           = 16
    delete_on_termination = true
  }

  target_group_arns = [module.load_balancers.target_group_arns["scaling_group"], module.load_balancers.target_group_arns["node_exporter"]]
  subnet_ids = [module.network.private_subnet_ids["vpc_a.subnet_3"],
  module.network.private_subnet_ids["vpc_a.subnet_4"]]
  security_group_ids = [module.vpc_a_security.security_group_id["asg_security"]]
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

  private_subnet_ids  = [module.network.private_subnet_ids["vpc_a.subnet_3"], module.network.private_subnet_ids["vpc_a.subnet_4"]]
  vpc_security_groups = [module.vpc_a_security.security_group_id["database_security"]]

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

module "cloudwatch" {
  source = "./modules/cloud_watch"

  sns_destinations = {
    on_call_guy = {
      display_name = "on_call_alerts"
      route = {
        email = {
          protocol_name = "email"
          endpoint      = var.email
        }
      }
    }
  }

  metric_alarms = {
    llm_high_db_storage = {
      alarm_name          = "[llm]-[test]-[db]-[high]-[storage]"
      alarm_description   = "database is running out of space"
      comparison_operator = "LessThanThreshold"
      metric_name         = "FreeStorageSpace"
      metric_namespace    = "AWS/RDS"

      evaluation_periods = 3
      collection_period  = 300
      metric_statistic   = "Average"
      alarm_threshold    = 2 * 1024 * 1024 * 1024
      metric_dimensions = {
        DBInstanceIdentifier = module.database.db_instance_id
      }
      treat_missing_data = "notBreaching"
      perform_actions    = true
      sns_topic_key      = "on_call_guy"
    }

    llm_db_high_cpu = {
      alarm_name          = "[llm]-[test]-[db]-[high]-[cpu]"
      alarm_description   = "database cpu is overwhelmed"
      comparison_operator = "GreaterThanThreshold"
      metric_name         = "CPUUtilization"
      metric_namespace    = "AWS/RDS"

      evaluation_periods = 3
      collection_period  = 300
      metric_statistic   = "Average"
      alarm_threshold    = 80
      metric_dimensions = {
        DBInstanceIdentifier = module.database.db_instance_id
      }
      treat_missing_data = "notBreaching"
      perform_actions    = true
      sns_topic_key      = "on_call_guy"
    }

    llm_alb_high_host_count = {
      alarm_name          = "[llm]-[test]-[elb]-[high]-[host-count]"
      alarm_description   = "ALB has an unhealthy number of healthy hosts"
      comparison_operator = "LessThanThreshold"
      metric_name         = "HealthyHostCount"
      metric_namespace    = "AWS/ApplicationELB"
      evaluation_periods  = 2
      collection_period   = 300
      metric_statistic    = "Average"
      alarm_threshold     = 1
      metric_dimensions = {
        TargetGroup  = module.load_balancers.target_group_id["scaling_group"]
        LoadBalancer = module.load_balancers.load_balancer_id["internal_alb"]
      }
      treat_missing_data = "breaching"
      perform_actions    = true
      sns_topic_key      = "on_call_guy"
    }

    llm_alb_medium_4xx_errors = {
      alarm_name          = "[llm]-[test]-[elb]-[medium]-[4XX-errors]"
      alarm_description   = "ALB is receiving excessive 4XX responses"
      comparison_operator = "GreaterThanThreshold"
      metric_name         = "HTTPCode_ELB_4XX_Count"
      metric_namespace    = "AWS/ApplicationELB"
      evaluation_periods  = 2
      collection_period   = 300
      metric_statistic    = "Sum"
      alarm_threshold     = 20
      metric_dimensions = {
        LoadBalancer = module.load_balancers.load_balancer_id["internal_alb"]
      }
      treat_missing_data = "notBreaching"
      perform_actions    = true
      sns_topic_key      = "on_call_guy"
    }

    llm_alb_medium_5xx_errors = {
      alarm_name          = "[llm]-[test]-[elb]-[medium]-[5XX-errors]"
      alarm_description   = "ALB is receiving excessive 5XX responses"
      comparison_operator = "GreaterThanThreshold"
      metric_name         = "HTTPCode_ELB_5XX_Count"
      metric_namespace    = "AWS/ApplicationELB"
      evaluation_periods  = 2
      collection_period   = 300
      metric_statistic    = "Sum"
      alarm_threshold     = 5
      metric_dimensions = {
        LoadBalancer = module.load_balancers.load_balancer_id["internal_alb"]
      }
      treat_missing_data = "notBreaching"
      perform_actions    = true
      sns_topic_key      = "on_call_guy"
    }
  }
}
