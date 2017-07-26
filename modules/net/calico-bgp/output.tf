output "id" {
  value = "${ var.enabled ? "${sha1("${join(" ", local_file.calico-bgp.*.id)}")}" : "# calico-bgp disabled"}"
}

output "name" {
  value = "contiv"
}
