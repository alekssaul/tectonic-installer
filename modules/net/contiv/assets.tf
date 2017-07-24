data "template_file" "contiv" {
  template = "${file("${path.module}/resources/manifests/contiv.yaml")}"

  vars {
    etcd_version   = "v2.3.8"
    netmaster_ip   = "netmaster"
    contiv_version = "1.1.1"
    vlan_if        = ""
    bootkube_id    = "${var.bootkube_id}"
    etcd_server    = "${var.etcd_server}"
    api_server     = "${var.api_server}"
    svc_subnet     = "${var.svc_subnet}"
    tls_key = "${base64encode(tls_private_key.contiv.private_key_pem)}"
    tls_cert = "${base64encode(tls_self_signed_cert.contiv.cert_pem)}"
    
  }
}

resource "local_file" "contiv" {
  count    = "${ var.enabled ? 1 : 0 }"
  content  = "${data.template_file.contiv.rendered}"
  filename = "./generated/manifests/contiv.yaml"
}

resource "tls_private_key" "contiv" { 
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "contiv" {

  key_algorithm   = "${tls_private_key.contiv.algorithm}"
  private_key_pem = "${tls_private_key.contiv.private_key_pem}"

  subject {
    common_name  = "auth-local.cisco.com"
    organization = "CPSG"
    organizational_unit = "IT Department"
    locality = "San Jose"
    province = "CA"
    country = "US"

  }

  is_ca_certificate     = true
  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]
}