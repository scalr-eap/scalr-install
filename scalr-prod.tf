terraform {
  backend "remote" {
    hostname = "my.scalr.com"
    organization = "org-sh20ttfrfn0ur28"
    workspaces {
      name = "tf-scalr-install"
    }
  }
}

provider "aws" {
    access_key = "${var.scalr_aws_access_key}"
    secret_key = "${var.scalr_aws_secret_key}"
    region     = var.region
}

###############################
#
# Proxy Server

resource "aws_instance" "proxy_1" {
  ami             = var.amis[var.region]
  instance_type   = var.instance_type
  key_name        = var.key_name
  vpc_security_group_ids = [ "${data.aws_security_group.default_sg.id}", "${aws_security_group.scalr_sg.id}", "${aws_security_group.proxy_sg.id}"]
  subnet_id       = var.subnet

  tags = {
    Name = "PG-proxy-1"
  }

  connection {
        host	= self.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file("./ssh/id_rsa")}"
        timeout  = "20m"
  }

  provisioner "file" {
        source = "./ssh/id_rsa"
        destination = "~/.ssh/id_rsa"

  }

  provisioner "file" {
      source = "./scalr_install_1.sh"
      destination = "/var/tmp/scalr_install_1.sh"

  }

  provisioner "file" {
      source = "./CFG/scalr-server-local.rb-proxy_app"
      destination = "/var/tmp/scalr-server-local.rb"

  }

  provisioner "file" {
      source = "./CFG/license.json"
      destination = "/var/tmp/license.json"

  }

  provisioner "remote-exec" {
      inline = [
        "chmod +x /var/tmp/scalr_install_1.sh",
        "sudo /var/tmp/scalr_install_1.sh '${var.token}'",
      ]
  }

}


###############################
#
# MySQL Servers

resource "aws_instance" "mysql_master" {
  ami             = var.amis[var.region]
  instance_type   = var.instance_type
  key_name        = var.key_name
  vpc_security_group_ids = [ "${data.aws_security_group.default_sg.id}", "${aws_security_group.mysql_sg.id}","${aws_security_group.scalr_sg.id}"]
  subnet_id       = var.subnet

  tags = {
    Name = "PG-mysql-master"
  }

  connection {
        host	= self.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file("./ssh/id_rsa")}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./scalr_install_1.sh"
      destination = "/var/tmp/scalr_install_1.sh"

  }

  provisioner "file" {
      source = "./CFG/scalr-server-local.rb-mysql_master"
      destination = "/var/tmp/scalr-server-local.rb"

  }

  provisioner "file" {
      source = "./CFG/license.json"
      destination = "/var/tmp/license.json"

  }

  provisioner "remote-exec" {
      inline = [
        "chmod +x /var/tmp/scalr_install_1.sh",
        "sudo /var/tmp/scalr_install_1.sh '${var.token}'",
      ]
  }

}


#resource "aws_instance" "mysql_slave" {
#  ami             = var.amis[var.region]
#  instance_type   = var.instance_type
#  key_name        = var.key_name
#  vpc_security_group_ids = [ "${data.aws_security_group.default_sg.id}", "${aws_security_group.mysql_sg.id}","${aws_security_group.scalr_sg.id}"]
#  subnet_id       = var.subnet
#
#  tags = {
#    Name = "PG-mysql-slave"
#  }
#
#  }


###############################
#
# Worker Server

resource "aws_instance" "worker" {
  ami             = var.amis[var.region]
  instance_type   = var.instance_type
  key_name        = var.key_name
  vpc_security_group_ids = [ "${data.aws_security_group.default_sg.id}", "${aws_security_group.scalr_sg.id}", "${aws_security_group.worker_sg.id}"]
  subnet_id       = var.subnet

  tags = {
    Name = "PG-worker"
  }

  connection {
        host	= self.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file("./ssh/id_rsa")}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./scalr_install_1.sh"
      destination = "/var/tmp/scalr_install_1.sh"

  }

  provisioner "file" {
      source = "./CFG/scalr-server-local.rb-worker"
      destination = "/var/tmp/scalr-server-local.rb"

  }

  provisioner "file" {
      source = "./CFG/license.json"
      destination = "/var/tmp/license.json"

  }

  provisioner "remote-exec" {
      inline = [
        "chmod +x /var/tmp/scalr_install_1.sh",
        "sudo /var/tmp/scalr_install_1.sh '${var.token}'",
      ]
  }

}

###############################
#
# Influxdb Server

resource "aws_instance" "influxdb" {
  ami             = var.amis[var.region]
  instance_type   = var.instance_type
  key_name        = var.key_name
  vpc_security_group_ids = [ "${data.aws_security_group.default_sg.id}", "${aws_security_group.scalr_sg.id}"]
  subnet_id       = var.subnet

  tags = {
    Name = "PG-influxdb"
  }

  connection {
        host	= self.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file("./ssh/id_rsa")}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./scalr_install_1.sh"
      destination = "/var/tmp/scalr_install_1.sh"

  }

  provisioner "file" {
      source = "./CFG/scalr-server-local.rb-influxDB"
      destination = "/var/tmp/scalr-server-local.rb"

  }

  provisioner "file" {
      source = "./CFG/license.json"
      destination = "/var/tmp/license.json"

  }

  provisioner "remote-exec" {
      inline = [
        "chmod +x /var/tmp/scalr_install_1.sh",
        "sudo /var/tmp/scalr_install_1.sh '${var.token}'",
      ]
  }

}

####################
# Now set the scalr-server.rb file everywhere, copy files into place and reconfigure

#data "null_data_source" "ips" {
#  inputs = {
#    all_server_ips = "${concat(aws_instance.mysql_master.*.public_ip, aws_instance.worker.*.public_ip, aws_instance.influxdb.*.public_ip, aws_instance.proxy_1.*.public_ip )}"
#  }
#
#}

# Copy secrets from proxy to other Servers

resource "null_resource" "create_config" {
  depends_on = [aws_instance.proxy_1, aws_instance.mysql_master, aws_instance.worker, aws_instance.influxdb]

  connection {
        host	= aws_instance.proxy_1.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file("./ssh/id_rsa")}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./scalr_install_set_config.sh"
      destination = "/var/tmp/scalr_install_set_config.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /var/tmp/scalr_install_set_config.sh",
      "/var/tmp/scalr_install_set_config.sh ${aws_instance.proxy_1.public_ip} ${aws_instance.proxy_1.private_ip} ${aws_instance.mysql_master.private_ip} ${aws_instance.worker.private_ip} ${aws_instance.influxdb.private_ip}",
    ]
  }

}

resource "null_resource" "copy_config" {
  depends_on = [null_resource.create_config]

  connection {
        host	= aws_instance.proxy_1.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file("./ssh/id_rsa")}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./copy_config.sh"
      destination = "/var/tmp/copy_config.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /var/tmp/copy_config.sh",
      "/var/tmp/copy_config.sh ${aws_instance.mysql_master.private_ip} ${aws_instance.worker.private_ip} ${aws_instance.influxdb.private_ip}",
    ]
  }
}

# MySQL MASTER

resource "null_resource" "configure_mysql_1" {
  depends_on = [null_resource.copy_config]
  connection {
        host	= aws_instance.mysql_master.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file("./ssh/id_rsa")}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./scalr_install_2.sh"
      destination = "/var/tmp/scalr_install_2.sh"

  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /var/tmp/scalr_install_2.sh",
      "sudo /var/tmp/scalr_install_2.sh",
    ]
  }
}

# Worker

resource "null_resource" "configure_worker" {

  depends_on = ["null_resource.configure_mysql_1"]
  connection {
        host	= aws_instance.worker.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file("./ssh/id_rsa")}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./scalr_install_2.sh"
      destination = "/var/tmp/scalr_install_2.sh"

  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /var/tmp/scalr_install_2.sh",
      "sudo /var/tmp/scalr_install_2.sh",
    ]
  }
}

# influxdb

resource "null_resource" "configure_influxdb" {

  depends_on = ["null_resource.configure_worker"]
  connection {
        host	= aws_instance.influxdb.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file("./ssh/id_rsa")}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./scalr_install_2.sh"
      destination = "/var/tmp/scalr_install_2.sh"

  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /var/tmp/scalr_install_2.sh",
      "sudo /var/tmp/scalr_install_2.sh",
    ]
  }
}

# Proxy 1

resource "null_resource" "configure_proxy_1" {

  depends_on = ["null_resource.configure_worker"]
  connection {
        host	= aws_instance.proxy_1.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file("./ssh/id_rsa")}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./scalr_install_2.sh"
      destination = "/var/tmp/scalr_install_2.sh"

  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /var/tmp/scalr_install_2.sh",
      "sudo /var/tmp/scalr_install_2.sh",
    ]
  }
}

resource "null_resource" "get_info" {

  depends_on = [null_resource.configure_proxy_1, null_resource.configure_influxdb]
  connection {
        host	= aws_instance.proxy_1.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file("./ssh/id_rsa")}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./get_pass.sh"
      destination = "/var/tmp/get_pass.sh"

  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /var/tmp/get_pass.sh",
      "sudo /var/tmp/get_pass.sh",
    ]
  }

}

output "mysql_master_public_ip" {
  value = aws_instance.mysql_master.public_ip
}
#output "mysql_slave_public_ip" {
#  value = aws_instance.mysql_slave.public_ip
#}
output "worker_public_ip" {
  value = aws_instance.worker.public_ip
}
output "influxdb_public_ip" {
  value = aws_instance.influxdb.public_ip
}
output "scalr_proxy_public_ip" {
  value = aws_instance.proxy_1.public_ip
}
output "mysql_master_private_ip" {
  value = aws_instance.mysql_master.private_ip
}
#output "mysql_slave_private_ip" {
#  value = aws_instance.mysql_slave.private_ip
#}
output "worker_private_ip" {
  value = aws_instance.worker.private_ip
}
output "influxdb_private_ip" {
  value = aws_instance.influxdb.private_ip
}
output "scalr_proxy_private_ip" {
  value = aws_instance.proxy_1.private_ip
}
