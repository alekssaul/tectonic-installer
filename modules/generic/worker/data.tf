data "template_file" "ignition" {
  template = "${file("${path.module}/resources/ignition.json")}"
  count = "${var.count}"

  vars {
		ignition = "${ignition_config.worker.*.rendered[count.index]}"

  }
}

data "template_file" "ignition-b64" {
  template = "${file("${path.module}/resources/ignition.json.b64")}"
  count = "${var.count}"

  vars {
  	ignition = "${base64encode(ignition_config.worker.*.rendered[count.index])}"
  }
}

resource "localfile_file" "ignition" {
  count = "${var.count}"
  content = "${data.template_file.ignition.*.rendered[count.index]}"
  destination = "${path.cwd}/ignition/ignition-${var.hostname["${count.index}"]}.json"
}

resource "localfile_file" "ignition-b64" {
  count = "${var.count}"
  content = "${data.template_file.ignition-b64.*.rendered[count.index]}"
  destination = "${path.cwd}/ignition/ignition-${var.hostname["${count.index}"]}-b64.json"

}
