variable "allowed_ips" {
  description = "The allowed IPs for the bastion security group"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "personal_arn" {
  description = "The ARN of the personal IAM user"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}
