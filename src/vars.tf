variable "EnvironmentName" {
    type = string
}
variable "BranchName" {
    type = string
    default = "master"
}
variable "VpcCIDR" {
    type = string
}

variable "public_subnet_cidr" {
    type = list(string)
}
variable "private_subnet_cidr" {
    type = list(string)
}
variable "serviceBaseName" {
    type = string
}
variable "registryUrl" {
    type = string
}
variable "cpu" {
    type = string
}
variable "memory" {
    type = string
}
variable "root_domain" {
    type = string
}
variable "subnet_count" {
  description = "List of 8-bit numbers of subnets of base_cidr_block that should be granted access."
  default = [1, 2]
}