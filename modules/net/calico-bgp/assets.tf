data "template_file" "calico-bgp" {
  template = "${file("${path.module}/resources/manifests/calico.yaml")}"

  vars {
    bootkube_id  = "${var.bootkube_id}"
    service_cidr = "${var.service_cidr}"
  }
}

resource "local_file" "calico-bgp" {
  count    = "${ var.enabled ? 1 : 0 }"
  content  = "${data.template_file.calico-bgp.rendered}"
  filename = "./generated/manifests/calico.yaml"
}


