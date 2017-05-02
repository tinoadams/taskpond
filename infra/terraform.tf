variable "scaleway_api_key" {}

variable "scaleway_access_token" {}

variable "gateway_count" {
  default = 1
}

provider "scaleway" {
  organization = "${var.scaleway_api_key}"
  token        = "${var.scaleway_access_token}"
  region       = "par1"
}

data "scaleway_bootscript" "docker" {
  architecture = "x86_64"
  name_filter  = "docker"
}

resource "scaleway_ip" "public_ip" {
  count = "${var.gateway_count}"
  server = "${element(scaleway_server.gateway.*.id, count.index)}"
}

resource "scaleway_server" "gateway" {
  count = "${var.gateway_count}"
  name  = "gateway_${count.index}"
  image = "89457135-d446-41ba-a8df-d53e5bb54710"
  bootscript = "${data.scaleway_bootscript.docker.id}"
  type  = "C2S"
  connection {
    private_key = "${file("ssh/deployer")}"
  }
  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get upgrade -y",
      "curl https://releases.rancher.com/install-docker/1.12.sh | sh",
      "docker run -d --restart=unless-stopped -p 8080:8080 rancher/server",
    ]
  }
}

output "gateway_public_ip" {
  value = "${join(",", scaleway_server.gateway.*.public_ip)}"
}

output "gateway_private_ip" {
  value = "${join(",", scaleway_server.gateway.*.private_ip)}"
}