resource "ignition_config" "etcd" {
  count = "${length(var.external_endpoints) == 0 ? var.count : 0}"

  users = [
    "${ignition_user.core.id}",
  ]

  files = [
    "${ignition_file.hostname-etcd.*.id[count.index]}",
    "${ignition_file.profile-env.id}",
    "${ignition_file.default-env.id}",
  ]

  systemd = [
    "${ignition_systemd_unit.etcd3.*.id[count.index]}",
    "${ignition_systemd_unit.vmtoolsd_member.id}",
  ]

  networkd = [
  "${ignition_networkd_unit.vmnetwork.*.id[count.index]}",
  ]
}

resource "ignition_file" "profile-env" {
  path       = "/etc/profile.env"
  mode       = 0644
  uid        = 0
  filesystem = "root"

  content {
    content = <<EOF
export HTTP_PROXY=${var.http_proxy}
export HTTPS_PROXY=${var.https_proxy}
export NO_PROXY=127.0.0.1
EOF
  }
}

resource "ignition_file" "default-env" {
  path       = "/etc/systemd/system.conf.d/10-default-env.conf"
  mode       = 0644
  uid        = 0
  filesystem = "root"

  content {
    content = <<EOF
[Manager]
DefaultEnvironment=HTTP_PROXY=${var.http_proxy}"
DefaultEnvironment=HTTPS_PROXY=${var.https_proxy}"
DefaultEnvironment=NO_PROXY=127.0.0.1
EOF
  }
}

resource "ignition_networkd_unit" "vmnetwork" {
    count      = "${var.count}"
    name = "00-ens192.network"
    content = <<EOF
[Match]
Name=ens192
[Network]
DNS=${var.dns_server}
Address=${var.ip_address["${count.index}"]}
Gateway=${var.gateway}
UseDomains=yes
Domains=${var.base_domain}
EOF
}

resource "ignition_systemd_unit" "etcd3" {
  count  = "${length(var.external_endpoints) == 0 ? var.count : 0}"
  name   = "etcd-member.service"
  enable = true

  dropin = [
    {
      name = "40-etcd-cluster.conf"

      content = <<EOF
[Service]
Environment="ETCD_IMAGE=${var.container_image}"
ExecStart=
ExecStart=/usr/lib/coreos/etcd-wrapper \
  --name=${var.cluster_name}-etcd-${count.index} \
  --advertise-client-urls=http://${var.cluster_name}-etcd-${count.index}.${var.base_domain}:2379 \
  --initial-advertise-peer-urls=http://${var.cluster_name}-etcd-${count.index}.${var.base_domain}:2380 \
  --listen-client-urls=http://0.0.0.0:2379 \
  --listen-peer-urls=http://0.0.0.0:2380 \
  --initial-cluster="${join("," , data.template_file.etcd-cluster.*.rendered)}" 
EOF
    },
  ]
}

data "template_file" "etcd-cluster" {
  template = "${file("${path.module}/resources/etcd-cluster")}"
  count = "${var.count}"
  vars = {
    etcd-name = "${var.cluster_name}-etcd-${count.index}"
    etcd-address = "${var.cluster_name}-etcd-${count.index}.${var.base_domain}"
  }

}

resource "ignition_file" "hostname-etcd" {
  count      = "${var.count}"
  path       = "/etc/hostname"
  mode       = 0644
  uid        = 0
  filesystem = "root"

  content {
    content = "${var.hostname["${count.index}"]}"
  }
}

resource "ignition_systemd_unit" "vmtoolsd_member" {
  name = "vmtoolsd.service"
  enable = true
  content = <<EOF
  [Unit]
  Description=VMware Tools Agent
  Documentation=http://open-vm-tools.sourceforge.net/
  ConditionVirtualization=vmware
  [Service]
  ExecStartPre=/usr/bin/ln -sfT /usr/share/oem/vmware-tools /etc/vmware-tools
  ExecStart=/usr/share/oem/bin/vmtoolsd
  TimeoutStopSec=5
EOF
}

resource "ignition_user" "core" {
  name                = "core"
  ssh_authorized_keys = ["${var.core_public_keys}"]
}
