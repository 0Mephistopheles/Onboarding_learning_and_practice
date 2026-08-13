resource "aws_launch_template" "launch_plan" {
  name                   = var.launch_template_name
  vpc_security_group_ids = var.security_group_ids

  image_id      = var.instance_system_type.ami_image_type
  instance_type = var.instance_system_type.instance_type
  key_name      = var.instance_key

  block_device_mappings {
    device_name = var.device_root

    ebs {
      volume_size           = var.instance_volume.volume_size
      volume_type           = var.instance_volume.volume_type
      delete_on_termination = var.instance_volume.delete_on_termination
    }
  }

  lifecycle {
    create_before_destroy = var.ensure_replacement
  }
}

resource "aws_autoscaling_group" "scaling_plan" {
  name = var.group_name

  min_size         = var.group_min_size
  max_size         = var.group_max_size
  desired_capacity = var.group_capacity

  vpc_zone_identifier = var.subnet_ids

  health_check_type         = var.check_type
  health_check_grace_period = var.check_period

  launch_template {
    id      = aws_launch_template.launch_plan.id
    version = aws_launch_template.launch_plan.latest_version
  }

  lifecycle {
    create_before_destroy = var.ensure_replacement

    ignore_changes = [
      desired_capacity
    ]
  }
}

resource "aws_autoscaling_policy" "scaling_policy" {
  count = var.enable_scaling ? 1 : 0

  name                   = var.scaling_policy_name
  autoscaling_group_name = aws_autoscaling_group.scaling_plan.name
  policy_type            = var.scaling_type

  target_tracking_configuration {
    target_value = var.cpu_threshold

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}