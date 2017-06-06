resource "null_resource" "etcd_secrets" {
  count = "${var.tectonic_etcd_count}"

  connection {
    type    = "ssh"
    host    = "${element(module.etcd.ip_address, count.index)}"
    user    = "core"
    timeout = "60m"
  }

  provisioner "file" {
    content     = "${module.bootkube.etcd_ca_crt_pem}"
    destination = "$HOME/etcd_ca.crt"
  }

  provisioner "file" {
    content     = "${module.bootkube.etcd_crt_pem}"
    destination = "$HOME/etcd_client.crt"
  }

  provisioner "file" {
    content     = "${module.bootkube.etcd_key_pem}"
    destination = "$HOME/etcd_client.key"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/ssl/etcd",
      "sudo mv /home/core/etcd_ca.crt /etc/ssl/etcd/ca.crt",
      "sudo mv /home/core/etcd_client.crt /etc/ssl/etcd/client.crt",
      "sudo mv /home/core/etcd_client.key /etc/ssl/etcd/client.key",
    ]
  }
}

resource "null_resource" "bootstrap" {
  # Without depends_on, this remote-exec may start before the kubeconfig copy.  # Terraform only does one task at a time, so it would try to bootstrap  # Kubernetes and Tectonic while no Kubelets are running. Ensure all nodes  # receive a kubeconfig before proceeding with bootkube and tectonic.  #depends_on = ["null_resource.kubeconfig-masters"]

  connection {
    type    = "ssh"
    host    = "${module.masters.ip_address[0]}"
    user    = "core"
    timeout = "60m"
  }

  provisioner "file" {
    source      = "./generated"
    destination = "$HOME/tectonic"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt",
      "sudo rm -rf /opt/tectonic",
      "sudo mv /home/core/tectonic /opt/",
      "sudo systemctl start tectonic",
    ]
  }
}
