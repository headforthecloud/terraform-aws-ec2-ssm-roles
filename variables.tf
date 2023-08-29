variable instance_type {
  type        = string
  description = "default ec2 instance type"
  default     = "t2.micro"
}

variable enable_bastion {
  type        = bool
  default     = false
  description = "flag to enable creation of bastion host in public subnet"
}

variable enable_nat_gateway {
  type        = bool
  default     = true
  description = "flag to enable creation of NAT Gateway"
}

variable vpc_cidr {
  type = string
  default = "10.100.0.0/16"
  description = "CIDR range for vpc"
}

variable vpc_public_subnet_cidr {
  type = string
  default = "10.100.1.0/24"
  description = "CIDR range for vpc"
}

variable vpc_private_subnet_cidr {
  type = string
  default = "10.100.2.0/24"
  description = "CIDR range for vpc"
}