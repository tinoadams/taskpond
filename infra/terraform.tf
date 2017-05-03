variable "gateway_count" {
  default = 2
}

variable "bastion_host" {
  default = "163.172.172.59"
}

variable "instance_type" {
  default = "c1"
}

resource "scaleway_ip" "public_ip" {
  count = "${var.gateway_count}"
  server = "${element(scaleway_server.gateway.*.id, count.index)}"
}

data "scaleway_bootscript" "gateway_bootscript" {
  architecture = "x86_64" // arm, x86_64
  name_filter  = "docker"
}

data "scaleway_image" "gateway_image" {
  architecture = "x86_64" // arm, x86_64
  name_filter  = "Xenial"
}

resource "scaleway_server" "gateway" {
  count = "${var.gateway_count}"
  name  = "gateway_${count.index}"
  image = "${data.scaleway_image.gateway_image.id}"
  bootscript = "${data.scaleway_bootscript.gateway_bootscript.id}"
  type  = "C2S" // C1 (arm), C2S, C2M, C2L
}

output "gateway_public_ip" {
  value = "${join(" , ", scaleway_ip.public_ip.*.ip)}"
}

output "gateway_private_ip" {
  value = "${join(" , ", scaleway_server.gateway.*.private_ip)}"
}