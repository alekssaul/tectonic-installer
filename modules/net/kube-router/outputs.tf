output "id" {
  value = "${ var.enabled ? "${sha1("${join(" ", local_file.kube-router.*.id)}")}" : "# kube-router disabled"}"
}

output "name" {
  value = "kube-router"
}
