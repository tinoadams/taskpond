variable "server_count" {
  default = 1
}

variable "bastion_host" {
  default = "163.172.172.59"
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
  name  = "gateway_${count.index}"
  image = "${data.scaleway_image.gateway_image.id}"
  bootscript = "${data.scaleway_bootscript.gateway_bootscript.id}"
  type  = "C2S" // C1 (arm), C2S, C2M, C2L
  connection {
    type         = "ssh"
    user         = "root"
    host         = "${var.bastion_host}"
    agent        = true
  }
  provisioner "local-exec" {
    command = "./assign_public_ip.sh ${var.bastion_host} ${self.id}"
  }
  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.ssh && touch ~/.ssh/config && chmod 0600 ~/.ssh/config && echo -e 'Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile=/dev/null' > ~/.ssh/config",
      "curl -o /usr/local/bin/setup-tinc.sh 'https://raw.githubusercontent.com/tinoadams/scaleway-utils/master/tinc/setup-tinc.sh' && chmod +x /usr/local/bin/setup-tinc.sh",
      "curl -o /usr/local/bin/add-tinc.sh 'https://raw.githubusercontent.com/tinoadams/scaleway-utils/master/tinc/add-tinc.sh' && chmod +x /usr/local/bin/add-tinc.sh",
      "yes '' | setup-tinc.sh gateway 172.16.1.1",
    ]
  }
}

resource "scaleway_server" "server" {
  count = "${var.server_count}"
  name  = "server_${count.index}"
  image = "${data.scaleway_image.gateway_image.id}"
  bootscript = "${data.scaleway_bootscript.gateway_bootscript.id}"
  type  = "C2S" // C1 (arm), C2S, C2M, C2L
  connection {
    type         = "ssh"
    user         = "root"
    host         = "${self.private_ip}"
    bastion_host = "${var.bastion_host}"
    bastion_user = "root"
    agent        = true
  }
  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.ssh && touch ~/.ssh/config && chmod 0600 ~/.ssh/config && echo -e 'Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile=/dev/null' > ~/.ssh/config",
      "ssh -A ${scaleway_server.gateway.private_ip} 'add-tinc.sh ${self.private_ip} 172.16.1.${count.index + 2} ${self.name}'",
    ]
  }
}

output "bastion_host" {
  value = "${var.bastion_host}"
}

output "gateway_private_ip" {
  value = "${join(" , ", scaleway_server.gateway.private_ip)}"
}