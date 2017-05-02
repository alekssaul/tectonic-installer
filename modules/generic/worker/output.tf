/*
output "ip_address" {
  value = ["${vsphere_virtual_machine.worker_node.*.network_interface.0.ipv4_address}"]
}

output "ignition" {
	value = ["${base64encode(ignition_config.worker.*.rendered)}"]
}*/