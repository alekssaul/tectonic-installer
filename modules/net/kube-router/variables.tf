variable "bootkube_id" {
  type = "string"
}

variable "kuberouter_image" {
  description = "Container image for kube-router"
  type        = "string"
}

variable "busybox_image" {
  description = "Container image for busybox"
  type        = "string"
}

variable "enabled" {
  description = "If set to true, flannel networking will be deployed"
  default     = true
}
