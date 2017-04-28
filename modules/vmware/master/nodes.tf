resource "vsphere_virtual_machine" "master_node" {
  count           = "${var.count}"
  name            = "${var.hostname["${count.index}"]}"
  datacenter      = "${var.vmware_datacenter}"
  cluster         = "${var.vmware_cluster}"
  vcpu            = "${var.vm_vcpu}"
  memory          = "${var.vm_memory}"
  folder          = "${var.vmware_folder}"

  network_interface {
    label         = "${var.vm_network_label}"
  }

  disk {
    datastore     = "${var.vm_disk_datastore}"
    template      = "${var.vm_disk_template_folder}/${var.vm_disk_template}"
    type          = "thin"
  }

  custom_configuration_parameters {
    guestinfo.coreos.config.data.encoding = "base64"
    guestinfo.coreos.config.data = "${base64encode(ignition_config.master.*.rendered[count.index])}"
    // UUID enablement is requiremd for Kubernetes vSphere Integration
    // see; https://kubernetes.io/docs/getting-started-guides/vsphere/
<<<<<<< HEAD
    disk.enableUUID = "1"
=======
    disk.enableUUID = "1" 

>>>>>>> This commit moves VMware manifests to static IP networking and removes the AWS Route53 dependency. End User is expected to create DNS records in advance since the user already pre-allocates the IP addresses
  }

}
