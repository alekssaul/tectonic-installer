module "bootkube" {
  source         = "../../modules/bootkube"
  cloud_provider = "vsphere"

  kube_apiserver_url = "https://${var.tectonic_cluster_name}-k8s.${var.tectonic_base_domain}:443"
  oidc_issuer_url    = "https://${var.tectonic_cluster_name}.${var.tectonic_base_domain}:443/identity"

  # Platform-independent variables wiring, do not modify.
  container_images = "${var.tectonic_container_images}"

  ca_cert    = "${var.tectonic_ca_cert}"
  ca_key     = "${var.tectonic_ca_key}"
  ca_key_alg = "${var.tectonic_ca_key_alg}"

  service_cidr = "${var.tectonic_service_cidr}"
  cluster_cidr = "${var.tectonic_cluster_cidr}"

  kube_apiserver_service_ip = "${var.tectonic_kube_apiserver_service_ip}"
  kube_dns_service_ip       = "${var.tectonic_kube_dns_service_ip}"

  advertise_address = "0.0.0.0"
  anonymous_auth    = "false"

  oidc_username_claim = "email"
  oidc_groups_claim   = "groups"
  oidc_client_id      = "tectonic-kubectl"

  etcd_servers = ["http://127.0.0.1:2379"]
}

module "tectonic" {
  source   = "../../modules/tectonic"
  platform = "vsphere"

  base_address       = "${var.tectonic_cluster_name}.${var.tectonic_base_domain}:443"
  kube_apiserver_url = "https://${var.tectonic_cluster_name}-k8s.${var.tectonic_base_domain}:443"

  # Platform-independent variables wiring, do not modify.
  container_images = "${var.tectonic_container_images}"
  versions         = "${var.tectonic_versions}"

  license_path     = "${var.tectonic_license_path}"
  pull_secret_path = "${var.tectonic_pull_secret_path}"

  admin_email         = "${var.tectonic_admin_email}"
  admin_password_hash = "${var.tectonic_admin_password_hash}"

  update_channel = "${var.tectonic_update_channel}"
  update_app_id  = "${var.tectonic_update_app_id}"
  update_server  = "${var.tectonic_update_server}"

  ca_generated = "${module.bootkube.ca_cert == "" ? false : true}"
  ca_cert      = "${module.bootkube.ca_cert}"
  ca_key_alg   = "${module.bootkube.ca_key_alg}"
  ca_key       = "${module.bootkube.ca_key}"

  console_client_id = "tectonic-console"
  kubectl_client_id = "tectonic-kubectl"
  ingress_kind      = "HostPort"
}

resource "null_resource" "tectonic" {
  depends_on = ["module.tectonic", "module.masters", "module.cloudprovider"]

  connection {
    host        = "${var.tectonic_cluster_name}-k8s.${var.tectonic_base_domain}"
    private_key = "${module.secrets.core_private_key_pem}"
    user        = "core"
  }

  provisioner "file" {
    source      = "${path.cwd}/generated"
    destination = "$HOME/tectonic"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt",
      "sudo rm -rf /opt/tectonic",
      "sudo mv /home/core/tectonic /opt/",
      "sudo mv /opt/tectonic/cloudprovider/* /opt/tectonic/manifests/",
      "sudo systemctl start tectonic",
    ]
  }
}