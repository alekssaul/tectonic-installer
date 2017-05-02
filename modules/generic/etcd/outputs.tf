output "name" {
  #value = ["${var.hostname["${count.index}"]}"]
  #value = "${(ignition_file.hostname-etcd.content.*.id)}"

  value = ["${data.template_file.etcd-cluster-proxy.*.rendered}"]
}

/*output "ignition" {
	value = ["${base64encode(ignition_config.etcd.*.rendered[count.index])}"]

}*/