variable "count" {
  type = "string"
  description = "Number of nodes to be created."
}

variable "base_domain" {
  type = "string"
}

variable kube_image_tag {
  type = "string"
  description = "The hyperkube image tag"
}

variable kube_image_url {
  type = "string"
  description = "The hyperkube image url"
}

variable kubeconfig_content {
  type = "string"
  description = "The content of the kubeconfig file."
}

variable etcd_fqdns {
  type = "list"
  description = "The fqdns of the etcd endpoints."
}

variable "core_public_keys" {
  type = "list"
}

variable "cluster_name" {
  type = "string"
  description = "Hostname will be prefixed with this string"
}

variable "tectonic_versions" {
  type = "map"
}

variable "tectonic_kube_dns_service_ip" {
  type = "string"
}

variable vm_vcpu  {
  type = "string"
  description = "ETCD VMs vCPU count"
}

variable vm_memory  {
  type = "string"
  description = "ETCD VMs Memory size in MB"
}

variable vm_disk_template_folder  {
  type = "string"
  description = "vSphere Folder CoreOS Container Linux is located in"
}

variable dns_server {
  type = "string"
  description = "DNS Server of the nodes"
}

variable ip_address {
  type = "map"
  description = "IP Address of the node"
}

variable gateway {
  type = "string"
  description = "Gateway of the node"
}

variable hostname {
  type = "map"
  description = "Hostname of the node"
}

variable "http_proxy" {
  type = "string"
  description = "HTTP Proxy variable"
  default = ""
}

variable "https_proxy" {
  type = "string"
  description = "HTTPS Proxy variable"
  default = ""
}

variable "no_proxy" {
  type = "string"
  description = "NO_Proxy variable"
  default = ""
}