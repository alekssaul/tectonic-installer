/*
output "ip_address" {
  #value = ["${var.hostname["${count.index}"]}"]
  value = "${(ignition_file.hostname-master.content.*.id)}"

}
*/
/*
output "ignition" {
	value = ["${base64encode(ignition_config.master.*.rendered)}"]

}
*/
