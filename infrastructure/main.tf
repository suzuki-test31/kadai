#================================================
# Provider
#================================================
provider "aws" {
  region = var.region
}

#================================================
# Variables
#================================================
variable "project" {
  type    = string
  default = "kadai"
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "az_a" {
  type    = string
  default = "us-west-2a"
}

variable "az_b" {
  type    = string
  default = "us-west-2b"
}

# CICD Demo Trigger