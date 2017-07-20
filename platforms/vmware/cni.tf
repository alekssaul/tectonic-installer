module "kube-router" {
  source  = "../../modules/net/kube-router"
  enabled = "${var.tectonic_cni_provider == "kube-router" ? true : false}"

  kuberouter_image = "${var.tectonic_container_images["kube-router"]}"
  busybox_image    = "${var.tectonic_container_images["busybox"]}"

  bootkube_id = "${module.bootkube.id}"
}
