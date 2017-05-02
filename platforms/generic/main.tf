module "etcd" {
  source = "../../modules/generic/etcd"

  count                   = "${var.tectonic_etcd_count}"
  cluster_name            = "${var.tectonic_cluster_name}"
  core_public_keys        = ["${module.secrets.core_public_key_openssh}"]
  container_image         = "${var.tectonic_container_images["etcd"]}"
  base_domain             = "${var.tectonic_base_domain}"
  external_endpoints      = ["${compact(var.tectonic_etcd_servers)}"]
  hostname                = "${var.tectonic_vmware_vm_etcd_hostnames}"
  vm_vcpu                 = "${var.tectonic_vmware_etcd_vm_vcpu}"
  vm_memory               = "${var.tectonic_vmware_etcd_vm_memory}"
  vm_disk_template_folder = "${var.tectonic_vmware_vm_template_folder}"
  dns_server              = "${var.tectonic_vmware_vm_dns}"
  ip_address              = "${var.tectonic_vmware_vm_etcdips}"
  gateway                 = "${var.tectonic_vmware_vm_etcdgateway}"
  http_proxy              = "${var.tectonic_vmware_httpproxy}"
  https_proxy              = "${var.tectonic_vmware_httpsproxy}"
  no_proxy                = "${var.tectonic_vmware_noproxy}"

}

module "masters" {
  source = "../../modules/generic/master"

  kubeconfig_content           = "${module.bootkube.kubeconfig}"
  cluster_name                 = "${var.tectonic_cluster_name}"
  count                        = "${var.tectonic_master_count}"
  kube_image_url               = "${data.null_data_source.local.outputs.kube_image_url}"
  kube_image_tag               = "${data.null_data_source.local.outputs.kube_image_tag}"
  tectonic_versions            = "${var.tectonic_versions}"
  hostname                = "${var.tectonic_vmware_vm_master_hostnames}"
  base_domain             = "${var.tectonic_base_domain}"
  tectonic_kube_dns_service_ip = "${var.tectonic_kube_dns_service_ip}"
  vm_vcpu                 = "${var.tectonic_vmware_master_vm_vcpu}"
  vm_memory               = "${var.tectonic_vmware_master_vm_memory}"
  vm_disk_template_folder = "${var.tectonic_vmware_vm_template_folder}"
  etcd_fqdns              = ["${module.etcd.name}"]
  dns_server              = "${var.tectonic_vmware_vm_dns}"
  ip_address              = "${var.tectonic_vmware_vm_masterips}"
  gateway                 = "${var.tectonic_vmware_vm_mastergateway}"
  http_proxy              = "${var.tectonic_vmware_httpproxy}"
  https_proxy              = "${var.tectonic_vmware_httpsproxy}"
  no_proxy                = "${var.tectonic_vmware_noproxy}"

  core_public_keys = ["${module.secrets.core_public_key_openssh}"]
}

module "workers" {
  source = "../../modules/generic/worker"

  kubeconfig_content           = "${module.bootkube.kubeconfig}"
  cluster_name                 = "${var.tectonic_cluster_name}"
  count                        = "${var.tectonic_worker_count}"
  kube_image_url               = "${data.null_data_source.local.outputs.kube_image_url}"
  kube_image_tag               = "${data.null_data_source.local.outputs.kube_image_tag}"
  hostname                     = "${var.tectonic_vmware_vm_worker_hostnames}"
  tectonic_versions            = "${var.tectonic_versions}"
  tectonic_kube_dns_service_ip = "${var.tectonic_kube_dns_service_ip}"
  base_domain             = "${var.tectonic_base_domain}"
  vm_vcpu                 = "${var.tectonic_vmware_worker_vm_vcpu}"
  vm_memory               = "${var.tectonic_vmware_worker_vm_memory}"
  vm_disk_template_folder = "${var.tectonic_vmware_vm_template_folder}"
  etcd_fqdns              = ["${module.etcd.name}"]
  dns_server              = "${var.tectonic_vmware_vm_dns}"
  ip_address              = "${var.tectonic_vmware_vm_workerips}"
  gateway                 = "${var.tectonic_vmware_vm_workergateway}"
  core_public_keys = ["${module.secrets.core_public_key_openssh}"]
  http_proxy              = "${var.tectonic_vmware_httpproxy}"
  https_proxy              = "${var.tectonic_vmware_httpsproxy}"
  no_proxy                = "${var.tectonic_vmware_noproxy}"
}

data "null_data_source" "local" {
  inputs = {
    kube_image_url = "${element(split(":", var.tectonic_container_images["hyperkube"]), 0)}"
    kube_image_tag = "${element(split(":", var.tectonic_container_images["hyperkube"]), 1)}"
  }
}

module "secrets" {
  source       = "../../modules/vmware/secrets"
  cluster_name = "${var.tectonic_cluster_name}"
}
