variable "region" {
  description = "Région AWS"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "Type d'instance"
  type        = string
  default     = "t3.small"
}
