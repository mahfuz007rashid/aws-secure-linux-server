variable "region" {
  type    = string
  default = "ap-southeast-2"
}

variable "project_name" {
  type    = string
  default = "secure-linux"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "alert_email" {
  type        = string
  description = "Email address for CloudWatch alerts"
}