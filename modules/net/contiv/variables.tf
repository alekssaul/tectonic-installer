variable "bootkube_id" {
  type = "string"
}

variable "enabled" {
  description = "If set to true, flannel networking will be deployed"
  default     = true
}

variable "etcd_server" {
  type = "string"
}

variable "api_server" {
  type = "string"
}

variable "svc_subnet" {
  description = "If set to true, flannel networking will be deployed"
  default     = true
}

variable "master_node" {
  description = "If set to true, flannel networking will be deployed"
  default     = true
}