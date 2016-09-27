variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}

variable "vpc_name" {
  default = "sandbox"
}

variable "environment" {
  default = "dev"
}

variable "stack" {
  default = "test"
}

variable "vpc_cidr" {
  default = "10.50.0.0/16"
}

variable "vpc_r53_zone" {
  default = "dev.aws"
}

variable "subnets" {
  default = {
    "public_0" = "10.50.10.0/24"
    "public_1" = "10.50.11.0/24"
    "private_0" = "10.50.20.0/24"
    "private_1" = "10.50.21.0/24"
  }
}

variable "az" {
  default = {
    "0" = "eu-west-1a"
    "1" = "eu-west-1b"
  }
}
