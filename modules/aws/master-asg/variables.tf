variable "ssh_key" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "cl_channel" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "ec2_type" {
  type = "string"
}

variable "instance_count" {
  type = "string"
}

variable "subnet_ids" {
  type = "list"
}

variable "extra_sg_ids" {
  type = "list"
}

variable "base_domain" {
  type        = "string"
  description = "Domain on which the ELB records will be created"
}

variable "internal_zone_id" {
  type        = "string"
  description = "ID of the internal facing Route53 Hosted Zone on which the ELB records will be created"
}

variable "external_zone_id" {
  type        = "string"
  description = "ID of the public facing Route53 Hosted Zone on which the ELB records will be created"
}

variable "user_data" {
  type        = "string"
  description = "User-data content used to boot the instances"
}