variable "region" {
  description = "Région AWS"
  type        = string
  default     = "eu-north-1" # J'ai mis ta région actuelle au vu de tes logs précédents
}

variable "instance_type" {
  description = "Type d'instance"
  type        = string
  default     = "t3.micro"
}
