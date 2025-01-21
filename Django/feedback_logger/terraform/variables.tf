variable "allowed_ips" {
  description = "The allowed IPs for the bastion security group"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

