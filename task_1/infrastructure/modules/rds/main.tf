resource "aws_db_subnet_group" "database" {
  name       = "${var.db_user.db_name}-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "database" {
  engine         = var.db_type.db_engine
  engine_version = var.db_type.db_version

  instance_class    = var.db_type.db_class
  allocated_storage = var.db_storage.storage_size
  storage_type      = var.db_storage.storage_type

  db_name  = var.db_user.db_name
  username = var.db_user.user_name
  password = var.db_user.user_password
  
  skip_final_snapshot = var.skip_snapshot
  port                   = var.db_port
  multi_az               = var.is_multi_az
  publicly_accessible    = var.public_access
  db_subnet_group_name   = aws_db_subnet_group.database.name
  vpc_security_group_ids = var.vpc_security_groups
}