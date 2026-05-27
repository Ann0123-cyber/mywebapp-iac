variable "base_image_path" {
  description = "Path to base cloud image"
  default     = "/home/anna/images/ubuntu-24.04-cloud.img"
}

variable "ansible_public_key" {
  description = "SSH public key for ansible user"
  default     = "AAAAC3NzaC1lZDI1NTE5AAAAIMA/GqYtmjT8INwMTlu8dUPyyPK4+0KLbbTikD0RD6KX"
}