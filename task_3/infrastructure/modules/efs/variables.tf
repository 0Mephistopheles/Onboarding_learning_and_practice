variable "efs_volume" {
  type = object({
    volume_token = string
    is_encrypted = optional(bool, true)

    mount_targets = map(object({
      subnet_id       = string
      security_groups = list(string)
    }))

    access_points = map(object({
      posix_user = object({
        gid = number
        uid = number
      })

      root_directory = object({
        path        = string
        permissions = string
        owner_gid   = number
        owner_uid   = number
      })
    }))

    enable_backup = optional(bool, false)
  })
}