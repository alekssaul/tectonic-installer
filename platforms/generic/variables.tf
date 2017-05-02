variable "tectonic_vmware_vm_template_folder" {
  type          = "string"
  description   = "Folder for VM template of CoreOS Container Linux."
  default       = "/vm"
}

variable "tectonic_vmware_tectonicaddress" {
  type          = "string"
  description   = "FQDN of Tectonic cluster. Default syntax will be used if empty"
  default       = ""
}

variable "tectonic_vmware_apiaddress" {
  type          = "string"
  description   = "FQDN of Kubernetes API. Default syntax will be used if empty"
  default       = ""
}

// # Node Settings

variable "tectonic_vmware_etcd_vm_vcpu" {
  type          = "string"
  default       = "1"
  description   = "etcd node vCPU count"
}

variable "tectonic_vmware_etcd_vm_memory" {
  type          = "string"
  default       = "4096"
  description   = "etcd node Memory Size in MB"
}

variable "tectonic_vmware_master_vm_vcpu" {
  type          = "string"
  default       = "2"
  description   = "Master node vCPU count"
}

variable "tectonic_vmware_master_vm_memory" {
  type          = "string"
  default       = "4096"
  description   = "Master node Memory Size in MB"
}

variable "tectonic_vmware_worker_vm_vcpu" {
  type          = "string"
  default       = "2"
  description   = "Worker node vCPU count"
}

variable "tectonic_vmware_worker_vm_memory" {
  type          = "string"
  default       = "4096"
  description   = "Worker node Memory Size in MB"
}

variable "tectonic_vmware_vm_masterips" {
  type = "map"
  description = "terraform map of Virtual Machine IPs"
}

variable "tectonic_vmware_vm_master_hostnames" {
  type = "map"
  description = "terraform map of Virtual Machine Hostnames"
}


variable "tectonic_vmware_vm_mastergateway" {
  type = "string"
  description = "gateway IP address for Master Virtual Machine"
}

variable "tectonic_vmware_vm_workerips" {
  type = "map"
  description = "terraform map of Virtual Machine IPs"
}

variable "tectonic_vmware_vm_workergateway" {
  type = "string"
  description = "tgateway IP address for Worker Virtual Machine "
}

variable "tectonic_vmware_vm_worker_hostnames" {
  type = "map"
  description = "terraform map of Virtual Machine Hostnames"
}

variable "tectonic_vmware_vm_etcd_hostnames" {
  type = "map"
  description = "terraform map of Virtual Machine Hostnames"
}

variable "tectonic_vmware_vm_etcdips" {
  type = "map"
  description = "terraform map of Virtual Machine IPs"
}

variable "tectonic_vmware_vm_etcdgateway" {
  type = "string"
  description = "gateway IP address for etcd Virtual Machine "
}

variable "tectonic_vmware_vm_dns" {
  type = "string"
  description = "DNS Server in use by nodes"
}

variable "tectonic_vmware_dnsresolv" {
  type          = "string"
  default       = <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
  description   = "DNS Server for the infrastructure"
}

variable "tectonic_vmware_httpproxy" {
  type = "string"
  description = "HTTP Proxy variable"
  default = ""
}

variable "tectonic_vmware_httpsproxy" {
  type = "string"
  description = "HTTPS Proxy variable"
  default = ""
}

variable "tectonic_vmware_noproxy" {
  type = "string"
  description = "no_proxy variable, defaults to 127.0.0.1,localhost,.$cluster.domain"
  default = ""
}