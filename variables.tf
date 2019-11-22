variable "scalr_aws_secret_key" {}
variable "scalr_aws_access_key" {}

variable "token" {
  type = string
}

variable "license" {
  type = string
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "amis" {
  type = "map"
  default = {
    "us-east-1" = "ami-024a64a6685d05041"
    "us-west-2" = "ami-005bdb005fb00e791"
    "eu-central-1" = "ami-090f10efc254eaf55"
  }
}

variable "instance_type" {
  type = string
  default = "t3.medium"
}

variable "key_name" {
  type = string
  default = "PeterG"
}

variable "private_ssh_key" {
  description = "The SSH Private key itself. This will be formatted by the Terraform template"
  type = string
}

variable "ssh_private_key_file" {
  type = string
  description = "Private SSH key to connect to VMs"
  default     = "./ssh/id_rsa"
}

variable "vpc" {
  type = string
  default = "vpc-0206e948abadc6a29"
}

variable "subnet" {
  type = string
  default = "subnet-0ebb1058ad727cfdb"
}

variable "name_prefix" {
  type = string
  default = "TF"
}
