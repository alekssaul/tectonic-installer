// The flavor ID as given in `openstack flavor list`.
// Specifies the size (CPU/Memory/Drive) of the VM.
variable "tectonic_openstack_flavor_id" {
  type    = "string"
  default = "5cf64088-893b-46b5-9bb1-ee020277635d"
}

// The image ID as given in `openstack image list`.
// Specifies the OS image of the VM.
variable "tectonic_openstack_image_id" {
  type    = "string"
  default = "acdcd535-5408-40f3-8e88-ad8ebb6507e6"
}
