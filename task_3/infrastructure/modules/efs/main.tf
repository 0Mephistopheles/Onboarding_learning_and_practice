resource "aws_efs_file_system" "volume_system" {
  creation_token = var.efs_volume.volume_token
  encrypted      = var.efs_volume.is_encrypted
}

resource "aws_efs_mount_target" "volume_mount" {
  for_each = var.efs_volume.mount_targets

  file_system_id  = aws_efs_file_system.volume_system.id
  subnet_id       = each.value.subnet_id
  security_groups = each.value.security_groups
}

resource "aws_efs_access_point" "volume_access" {
  for_each = var.efs_volume.access_points

  file_system_id = aws_efs_file_system.volume_system.id
  posix_user {
    gid = each.value.posix_user.gid
    uid = each.value.posix_user.uid
  }

  root_directory {
    path = each.value.root_directory.path

    creation_info {
      permissions = each.value.root_directory.permissions
      owner_gid   = each.value.root_directory.owner_gid
      owner_uid   = each.value.root_directory.owner_uid
    }
  }
}

resource "aws_efs_backup_policy" "volume_backup" {
  file_system_id = aws_efs_file_system.volume_system.id

  backup_policy {
    status = var.efs_volume.enable_backup ? "ENABLED" : "DISABLED"
  }
}