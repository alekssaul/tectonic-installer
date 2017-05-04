resource "ignition_config" "master" {
  count = "${var.count}"

  users = [
    "${ignition_user.core.id}",
  ]

  files = [
    "${ignition_file.kubeconfig.id}",
    "${ignition_file.kubelet-env.id}",
    "${ignition_file.max-user-watches.id}",
    "${ignition_file.cloudprovider.id}",
    "${ignition_file.hostname-master.*.id[count.index]}",
    "${ignition_file.profile-env.*.id[count.index]}",
    "${ignition_file.default-env.*.id[count.index]}",
    "${ignition_file.registry-certificate.id}",
    "${ignition_file.dockerpull.id}",
  ]

  systemd = [
    "${ignition_systemd_unit.etcd-member.id}",
    "${ignition_systemd_unit.docker.id}",
    "${ignition_systemd_unit.locksmithd.id}",
    "${ignition_systemd_unit.kubelet-master.id}",
    "${ignition_systemd_unit.tectonic.id}",
    "${ignition_systemd_unit.update_ca_certs.id}",
    "${ignition_systemd_unit.docker_seed_pod-checkpointer.id}",
    "${ignition_systemd_unit.docker_seed_prometheus.id}",
  ]

  networkd = [
  "${ignition_networkd_unit.vmnetwork.*.id[count.index]}",
  ]
}

resource "ignition_systemd_unit" "docker" {
  name   = "docker.service"
  enable = true
  dropin = [
  {
    name =  "50-insecure-registry.conf"
    content =  "[Service]\nEnvironment=DOCKER_OPTS=--insecure-registry=${var.insecure-registry}\n"
  },
  ]
}

data "template_file" "profile-env" {
  template = "${file("${path.module}/resources/profile.env")}"

  vars {
    http_proxy   = "${var.http_proxy}"
    https_proxy = "${var.https_proxy}" 
    no_proxy = "${length(var.no_proxy) == 0 ? (null_resource.noproxy.triggers.no_proxy) : var.no_proxy}"
  }
}

resource "null_resource" "noproxy" {
    triggers = {
        no_proxy = "127.0.0.1,localhost,.${var.base_domain},${join(",", formatlist("%s", var.etcd_fqdns))}" 
    }
}

resource "ignition_file" "profile-env" {
  count      = "${length(var.enableproxy) == 0 ? var.count : 0 }"
  path       = "/etc/profile.env"
  mode       = 0644
  uid        = 0
  filesystem = "root"

  content {
    content = "${data.template_file.profile-env.rendered}"    
  }
}

data "template_file" "default-env" {
  template = "${file("${path.module}/resources/10-default-env.conf")}"

  vars {
    http_proxy   = "${var.http_proxy}"
    https_proxy = "${var.https_proxy}"        
    no_proxy = "${length(var.no_proxy) == 0 ? (null_resource.noproxy.triggers.no_proxy) : var.no_proxy}"
  }
}

resource "ignition_file" "default-env" {
  count      = "${length(var.enableproxy) == 0 ? var.count : 0 }"
  path       = "/etc/systemd/system.conf.d/10-default-env.conf"
  mode       = 0644
  uid        = 0
  filesystem = "root"

  content {
    content = "${data.template_file.default-env.rendered}"
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

resource "ignition_file" "hostname-master" {
  count      = "${var.count}"
  path       = "/etc/hostname"
  mode       = 0644
  uid        = 0
  filesystem = "root"

  content {
    content = "${var.hostname["${count.index}"]}"
  }
}

resource "ignition_systemd_unit" "locksmithd" {
  name = "locksmithd.service"

  dropin = [
    {
      name    = "40-etcd-lock.conf"
      content = "[Service]\nEnvironment=REBOOT_STRATEGY=etcd-lock\n"
    },
  ]
}

data "template_file" "kubelet-master" {
  template = "${file("${path.module}/resources/master-kubelet.service")}"

  vars {
    cluster_dns = "${var.tectonic_kube_dns_service_ip}"
    pause_container = "${var.container_images["pause"]}"
    cloud-config = "${var.cloud-config}"
  }
}

resource "ignition_systemd_unit" "kubelet-master" {
  name    = "kubelet.service"
  enable  = true
  content = "${data.template_file.kubelet-master.rendered}"
}

data "template_file" "etcd-member" {
  template = "${file("${path.module}/resources/etcd-member.service")}"

  vars {
    etcd_image = "${var.etcd_image}"
    endpoints = "${join(",", formatlist("%s:2379", var.etcd_fqdns))}"

  }
}

resource "ignition_systemd_unit" "etcd-member" {
  name   = "etcd-member.service"
  enable = true

  dropin = [
    {
      name    = "40-etcd-gateway.conf"
      content = "${data.template_file.etcd-member.rendered}"
    },
  ]
}

resource "ignition_file" "kubeconfig" {
  filesystem = "root"
  path       = "/etc/kubernetes/kubeconfig"
  mode       = "420"

  content {
    content = "${var.kubeconfig_content}"
  }
}

resource "ignition_file" "kubelet-env" {
  filesystem = "root"
  path       = "/etc/kubernetes/kubelet.env"
  mode       = "420"

  content {
    content = <<EOF
KUBELET_ACI=docker://${var.kube_image_url}
KUBELET_VERSION="${var.kube_image_tag}"
EOF
  }
}

resource "ignition_file" "max-user-watches" {
  filesystem = "root"
  path       = "/etc/sysctl.d/max-user-watches.conf"
  mode       = "420"

  content {
    content = "fs.inotify.max_user_watches=16184"
  }
}

resource "ignition_file" "cloudprovider" {
  #count      = "${length(var.cloud-config) == 0 ? var.count : 0 }"
  path       = "/etc/kubernetes/vsphere.conf"
  mode       = 0600
  uid        = 0
  filesystem = "root"

  content {
    content = <<EOF
[Global]
  user = "${var.vmware_username}"
  password = "${var.vmware_password}"
  server = "${var.vmware_server}"
  port = "443"
  insecure-flag = "${var.vmware_sslselfsigned}"
  datacenter = "${var.vmware_datacenter}"
  datastore = "${var.vmware_datastore}"
  working-dir = "${var.vmware_folder}"
[Disk]
  scsicontrollertype = "pvscsi"
EOF
  }
}

resource "ignition_systemd_unit" "tectonic" {
  name   = "tectonic.service"
  enable = true

  content = <<EOF
[Unit]
Description=Bootstrap a Tectonic cluster
[Service]
Type=oneshot
WorkingDirectory=/opt/tectonic
ExecStart=/usr/bin/bash /opt/tectonic/bootkube.sh
ExecStart=/usr/bin/bash /opt/tectonic/tectonic.sh kubeconfig tectonic
EOF
}

resource "ignition_file" "registry-certificate" { 
  path       = "/etc/ssl/certs/internal-registry.pem" 
  mode     = 0644 
  uid        = 0  
  filesystem = "root" 
 
  content { 
    content = "${var.container_registry_certificate}" 
  } 
} 

resource "ignition_systemd_unit" "update_ca_certs" {
  name   = "updateca.service"
  enable = true

  content = <<EOF
[Unit]
Description=Run update ca certs

[Service]
Type=oneshot
ExecStart=/usr/sbin/update-ca-certificates

[Install]
WantedBy=multi-user.target
EOF
}

resource "ignition_file" "dockerpull" {
  path       = "/root/docker_pull.sh"
  mode       = 0700
  uid        = 0
  filesystem = "root"

  content {
    content = <<EOF
#!/bin/sh
sleep 60
/usr/bin/docker pull $imagetopull
dockerimageid=$(/usr/bin/docker images $imagetopull --format "{{.ID}}") 
/usr/bin/docker tag $dockerimageid $imagetotag

EOF
  }
}

resource "ignition_systemd_unit" "docker_seed_pod-checkpointer" {
  name   = "seed-pod-checkpointer.service"
  enable = true

  content = <<EOF
[Unit]
Description=Seed Pod Checkpointer
Requires=docker.service,updateca.service
After=docker.service,updateca.service

[Service]
Type=oneshot
Environment=imagetopull=${var.container_images["pod-checkpointer"]}
Environment=imagetotag=quay.io/coreos/pod-checkpointer:5b585a2d731173713fa6871c436f6c53fa17f754
ExecStart=/usr/bin/bash /root/docker_pull.sh

[Install]
WantedBy=multi-user.target
EOF
}

resource "ignition_systemd_unit" "docker_seed_prometheus" {
  name   = "seed-prometheus.service"
  enable = true

  content = <<EOF
[Unit]
Description=Seed Pod Checkpointer
Requires=docker.service,updateca.service
After=docker.service,updateca.service

[Service]
Type=oneshot
Environment=imagetopull=${var.container_images["prometheus"]}
Environment=imagetotag=quay.io/prometheus/prometheus:v1.5.2
ExecStart=/usr/bin/bash /root/docker_pull.sh

[Install]
WantedBy=multi-user.target
EOF
}
