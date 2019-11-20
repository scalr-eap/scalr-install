variable "scalr_aws_secret_key" {}
variable "scalr_aws_access_key" {}

variable "ssh_key" {}

variable "token" {}
variable "region" {
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
   default = "t3.medium"
}

variable "key_name" {
  default = "PeterG"
}

variable "ssh_private_key" {
  description = "Private SSH key to connect to VMs"
  default     = "/Users/peterg/.ssh/id_rsa"
}

variable "vpc" {
  default = "vpc-0206e948abadc6a29"
}

variable "subnet" {
  default = "subnet-0ebb1058ad727cfdb"
}
