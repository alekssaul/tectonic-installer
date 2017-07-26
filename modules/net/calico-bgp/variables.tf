variable "enabled" {
  description = "If set to true, Calico-BGP networking will be deployed"
  default     = false
}

variable "service_cidr" {
  description = "Service CIDR set to in Kubernetes configration"
}

variable "bootkube_id" {
  description = "Bootkube ID"
}
