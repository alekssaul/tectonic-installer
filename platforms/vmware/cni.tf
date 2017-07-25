module "kube-router" {
  source  = "../../modules/net/kube-router"
  enabled = "${var.tectonic_cni_provider == "kube-router" ? true : false}"

  kuberouter_image = "${var.tectonic_container_images["kube-router"]}"
  busybox_image    = "${var.tectonic_container_images["busybox"]}"

  bootkube_id = "${module.bootkube.id}"
}

module "contiv" {
  source      = "../../modules/net/contiv"
  enabled     = "${var.tectonic_cni_provider == "contiv" ? true : false}"
  etcd_server = "${module.masters.ip_address[0]}"
  api_server  = "${module.masters.ip_address[0]}"
  bootkube_id = "${module.bootkube.id}"
  svc_subnet  = "${var.tectonic_service_cidr}"
  master_node = "${var.tectonic_vmware_master_hostnames["0"]}"
}
