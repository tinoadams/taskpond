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
    command = "curl -H 'X-Auth-Token: 50bcb3dc-cf23-4338-9fda-049962820a20' -H 'Content-Type: application/json' https://cp-par1.scaleway.com/ips | jq -r '.ips[]|select(.address == \"${var.bastion_host}\")|.id' > /tmp/ip_id && curl -H 'X-Auth-Token: 50bcb3dc-cf23-4338-9fda-049962820a20' -H 'Content-Type: application/json' -X PUT https://cp-par1.scaleway.com/ips/`cat /tmp/ip_id` -d \"{${format(replace("'id':'`cat /tmp/ip_id`','address':'%s','organization':'14b45181-66c1-4064-934c-bcb5fd2a2156','reverse':null,'server':'%s'","'",'"'),var.bastion_host,self.id)}\""
  }
  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.ssh && touch ~/.ssh/config && chmod 0600 ~/.ssh/config && echo -e 'Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile=/dev/null' > ~/.ssh/config",
      "curl -o /usr/local/bin/setup-tinc.sh 'https://raw.githubusercontent.com/tinoadams/scaleway-utils/master/tinc/setup-tinc.sh' && chmod +x /usr/local/bin/setup-tinc.sh",
      "curl -o /usr/local/bin/add-tinc.sh 'https://raw.githubusercontent.com/tinoadams/scaleway-utils/master/tinc/add-tinc.sh' && chmod +x /usr/local/bin/add-tinc.sh",
      "setup-tinc.sh gateway 172.16.1.1",
    ]
  }
}
/*
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
      "ssh -A ${scaleway_server.gateway.private_ip} 'add-tinc.sh ${self.private_ip} 172.16.1.${count.index + 1} ${self.name}'",
    ]
  }
}
*/
output "bastion_host" {
  value = "${var.bastion_host}"
}

output "gateway_private_ip" {
  value = "${join(" , ", scaleway_server.gateway.private_ip)}"
}