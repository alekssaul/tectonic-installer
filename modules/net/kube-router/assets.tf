data "template_file" "kube-router" {
  template = "${file("${path.module}/resources/manifests/kube-router.yaml")}"

  vars {
    kuberouter_image = "${var.kuberouter_image}"
    busybox_image    = "${var.busybox_image}"
    bootkube_id      = "${var.bootkube_id}"
  }
}

resource "local_file" "kube-router" {
  count = "${ var.enabled ? 1 : 0 }"

  content  = "${data.template_file.kube-router.rendered}"
  filename = "./generated/manifests/kube-router.yaml"
}
