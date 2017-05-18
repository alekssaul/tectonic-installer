data "ignition_config" "etcd" {
  count = "${length(var.external_endpoints) == 0 ? var.instance_count : 0}"

  systemd = [
    "${data.ignition_systemd_unit.locksmithd.id}",
    "${data.ignition_systemd_unit.etcd3.*.id[count.index]}",
  ]

  files = [
    "${data.ignition_file.node_hostname.*.id[count.index]}",
    "${data.ignition_file.etcd-ca.id}",
    "${data.ignition_file.etcd-crt.id}",
    "${data.ignition_file.etcd-key.id}",
  ]
}

data "ignition_file" "node_hostname" {
  count      = "${length(var.external_endpoints) == 0 ? var.instance_count : 0}"
  path       = "/etc/hostname"
  mode       = 0644
  filesystem = "root"

  content {
    content = "${var.cluster_name}-etcd-${count.index}.${var.base_domain}"
  }
}

data "ignition_file" "etcd-ca" {
  path       = "/etc/ssl/etcd/ca.crt"
  mode       = 0644
  filesystem = "root"

  content {
    content = "${var.tls_ca_crt_pem}"
  }
}

data "ignition_file" "etcd-key" {
  path       = "/etc/ssl/etcd/client.key"
  mode       = 0644
  filesystem = "root"

  content {
    content = "${var.tls_key_pem}"
  }
}

data "ignition_file" "etcd-crt" {
  path       = "/etc/ssl/etcd/client.crt"
  mode       = 0644
  filesystem = "root"

  content {
    content = "${var.tls_crt_pem}"
  }
}

data "ignition_systemd_unit" "locksmithd" {
  count = "${length(var.external_endpoints) == 0 ? 1 : 0}"

  name   = "locksmithd.service"
  enable = true

  dropin = [
    {
      name    = "40-etcd-lock.conf"
      content = "[Service]\nEnvironment=REBOOT_STRATEGY=etcd-lock\n"
    },
  ]
}

data "ignition_systemd_unit" "etcd3" {
  count  = "${length(var.external_endpoints) == 0 ? var.instance_count : 0}"
  name   = "etcd-member.service"
  enable = true

  dropin = [
    {
      name = "40-etcd-cluster.conf"

      content = <<EOF
[Service]
Environment="ETCD_IMAGE=${var.container_image}"
Environment="RKT_RUN_ARGS=--volume etcd-ssl,kind=host,source=/etc/ssl/etcd \
  --mount volume=etcd-ssl,target=/etc/ssl/etcd"
ExecStart=
ExecStart=/usr/lib/coreos/etcd-wrapper \
  --name=etcd \
  --discovery-srv=${var.base_domain} \
  --advertise-client-urls=${var.tls_enabled ? "https" : "http"}://${var.cluster_name}-etcd-${count.index}.${var.base_domain}:2379 \
  ${var.tls_enabled
      ? "--cert-file=/etc/ssl/etcd/client.crt --key-file=/etc/ssl/etcd/client.key --peer-cert-file=/etc/ssl/etcd/client.crt --peer-key-file=/etc/ssl/etcd/client.key --peer-trusted-ca-file=/etc/ssl/etcd/ca.crt -peer-client-cert-auth=true"
      : ""} \
  --initial-advertise-peer-urls=${var.tls_enabled ? "https" : "http"}://${var.cluster_name}-etcd-${count.index}.${var.base_domain}:2380 \
  --listen-client-urls=${var.tls_enabled ? "https" : "http"}://0.0.0.0:2379 \
  --listen-peer-urls=${var.tls_enabled ? "https" : "http"}://0.0.0.0:2380
EOF
    },
  ]
}
