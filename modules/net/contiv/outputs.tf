output "id" {
  value = "${ var.enabled ? "${sha1("${join(" ", local_file.contiv.*.id)}")}" : "# contiv disabled"}"
}

output "name" {
  value = "contiv"
}
