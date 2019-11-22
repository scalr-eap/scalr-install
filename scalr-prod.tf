terraform {
  backend "remote" {
    hostname = "my.scalr.com"
    organization = "xxxxxxxxxx"
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

# This inelegant code takes the SSH private key from the variable and turns it back into a properly formatted key with line breaks

resource "local_file" "ssh_key" {
    content     = var.private_ssh_key
    filename = "./ssh/temp_key"
}

resource "null_resource" "fix_key" {
  provisioner "local-exec" {
    command = "(HF=$(cat ./ssh/temp_key | cut -d' ' -f2-4);echo '-----BEGIN '$HF;cat ./ssh/temp_key | sed -e 's/--.*-- //' -e 's/--.*--//' | awk '{for (i = 1; i <= NF; i++) print $i}';echo '-----END '$HF) > ${var.ssh_private_key_file}"
  }
}

###############################
#
# Proxy Servers
#
# 1

resource "aws_instance" "proxy_1" {
  ami             = var.amis[var.region]
  instance_type   = var.instance_type
  key_name        = var.key_name
  vpc_security_group_ids = [ "${data.aws_security_group.default_sg.id}", "${aws_security_group.scalr_sg.id}", "${aws_security_group.proxy_sg.id}"]
  subnet_id       = var.subnet

  tags = {
    Name = "${var.name_prefix}-proxy-1"
  }

  connection {
        host	= self.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file(var.ssh_private_key_file)}"
        timeout  = "20m"
  }

  provisioner "file" {
        source = var.ssh_private_key_file
        destination = "~/.ssh/id_rsa"
  }

  provisioner "file" {
      source = "./SCRIPTS/scalr_install_1.sh"
      destination = "/var/tmp/scalr_install_1.sh"
  }

  provisioner "file" {
      source = "./CFG/scalr-server-local.rb-proxy_app"
      destination = "/var/tmp/scalr-server-local.rb"
  }

  provisioner "remote-exec" {
      inline = [
        "chmod +x /var/tmp/scalr_install_1.sh",
        "sudo /var/tmp/scalr_install_1.sh '${var.token}' '${var.license}'",
      ]
  }
}

#
# 2

resource "aws_instance" "proxy_2" {
  ami             = var.amis[var.region]
  instance_type   = var.instance_type
  key_name        = var.key_name
  vpc_security_group_ids = [ "${data.aws_security_group.default_sg.id}", "${aws_security_group.scalr_sg.id}", "${aws_security_group.proxy_sg.id}"]
  subnet_id       = var.subnet

  tags = {
    Name = "${var.name_prefix}-proxy-2"
  }

  connection {
        host	= self.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file(var.ssh_private_key_file)}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./SCRIPTS/scalr_install_1.sh"
      destination = "/var/tmp/scalr_install_1.sh"
  }

  provisioner "file" {
      source = "./CFG/scalr-server-local.rb-proxy_app"
      destination = "/var/tmp/scalr-server-local.rb"
  }

  provisioner "remote-exec" {
      inline = [
        "chmod +x /var/tmp/scalr_install_1.sh",
        "sudo /var/tmp/scalr_install_1.sh '${var.token}' '${var.license}'",
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
    Name = "${var.name_prefix}-mysql-master"
  }

  connection {
        host	= self.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file(var.ssh_private_key_file)}"
        timeout  = "20m"
  }

# NOTE: MySQL master scalr-server-local.rb cant be sent to server at this stage as we dont know slave IP
#       This is done later prior to reconfigure

  provisioner "file" {
      source = "./SCRIPTS/scalr_install_1.sh"
      destination = "/var/tmp/scalr_install_1.sh"
  }

  provisioner "remote-exec" {
      inline = [
        "chmod +x /var/tmp/scalr_install_1.sh",
        "sudo /var/tmp/scalr_install_1.sh '${var.token}' '${var.license}'",
      ]
  }
}

resource "aws_instance" "mysql_slave" {
  ami             = var.amis[var.region]
  instance_type   = var.instance_type
  key_name        = var.key_name
  vpc_security_group_ids = [ "${data.aws_security_group.default_sg.id}", "${aws_security_group.mysql_sg.id}","${aws_security_group.scalr_sg.id}"]
  subnet_id       = var.subnet

  tags = {
    Name = "${var.name_prefix}-mysql-slave"
  }
    connection {
          host	= self.public_ip
          type     = "ssh"
          user     = "ubuntu"
          private_key = "${file(var.ssh_private_key_file)}"
          timeout  = "20m"
    }

    provisioner "file" {
        source = "./SCRIPTS/scalr_install_1.sh"
        destination = "/var/tmp/scalr_install_1.sh"
    }

      provisioner "file" {
          source = "./CFG/scalr-server-local.rb-mysql_slave"
          destination = "/var/tmp/scalr-server-local.rb"
      }

      provisioner "remote-exec" {
          inline = [
            "chmod +x /var/tmp/scalr_install_1.sh",
            "sudo /var/tmp/scalr_install_1.sh '${var.token}' '${var.license}'",
          ]
      }
}


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
    Name = "${var.name_prefix}-worker"
  }

  connection {
        host	= self.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file(var.ssh_private_key_file)}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./SCRIPTS/scalr_install_1.sh"
      destination = "/var/tmp/scalr_install_1.sh"
  }

  provisioner "file" {
      source = "./CFG/scalr-server-local.rb-worker"
      destination = "/var/tmp/scalr-server-local.rb"
  }

  provisioner "remote-exec" {
      inline = [
        "chmod +x /var/tmp/scalr_install_1.sh",
        "sudo /var/tmp/scalr_install_1.sh '${var.token}' '${var.license}'",
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
    Name = "${var.name_prefix}-influxdb"
  }

  connection {
        host	= self.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file(var.ssh_private_key_file)}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./SCRIPTS/scalr_install_1.sh"
      destination = "/var/tmp/scalr_install_1.sh"
  }

  provisioner "file" {
      source = "./CFG/scalr-server-local.rb-influxDB"
      destination = "/var/tmp/scalr-server-local.rb"
  }

  provisioner "remote-exec" {
      inline = [
        "chmod +x /var/tmp/scalr_install_1.sh",
        "sudo /var/tmp/scalr_install_1.sh '${var.token}' '${var.license}'",
      ]
  }
}

# Load Balancer
#

resource "aws_elb" "scalr_lb" {
  name               = "scalr-lb"

  subnets         = [var.subnet]
  security_groups = ["${data.aws_security_group.default_sg.id}", "${aws_security_group.proxy_sg.id}"]
  instances       = ["${aws_instance.proxy_1.id}", "${aws_instance.proxy_2.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 5671
    instance_protocol = "http"
    lb_port           = 5671
    lb_protocol       = "http"
  }

  tags = {
    Name = "${var.name_prefix}-scalr-elb"
  }
}


# Copy secrets from proxy to other Servers

resource "null_resource" "create_config" {
  depends_on = [aws_instance.proxy_1, aws_instance.proxy_2, aws_instance.mysql_master, aws_instance.mysql_slave, aws_instance.worker, aws_instance.influxdb]

  connection {
        host	= aws_instance.proxy_1.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file(var.ssh_private_key_file)}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./SCRIPTS/scalr_install_set_config.sh"
      destination = "/var/tmp/scalr_install_set_config.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /var/tmp/scalr_install_set_config.sh",
      "/var/tmp/scalr_install_set_config.sh ${aws_elb.scalr_lb.dns_name} ${aws_instance.proxy_1.private_ip} ${aws_instance.proxy_2.private_ip} ${aws_instance.mysql_master.private_ip} ${aws_instance.mysql_slave.private_ip} ${aws_instance.worker.private_ip} ${aws_instance.influxdb.private_ip}",
    ]
  }

}

resource "null_resource" "copy_config" {
  depends_on = [null_resource.create_config]

  connection {
        host	= aws_instance.proxy_1.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file(var.ssh_private_key_file)}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./SCRIPTS/copy_config.sh"
      destination = "/var/tmp/copy_config.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /var/tmp/copy_config.sh",
      "/var/tmp/copy_config.sh ${aws_instance.proxy_2.private_ip} ${aws_instance.mysql_master.private_ip} ${aws_instance.mysql_slave.private_ip} ${aws_instance.worker.private_ip} ${aws_instance.influxdb.private_ip}",
    ]
  }
}

# MySQL MASTER 1

resource "null_resource" "configure_mysql_master_1" {
  depends_on = [null_resource.copy_config]
  connection {
        host	= aws_instance.mysql_master.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file(var.ssh_private_key_file)}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./SCRIPTS/mysql_master_config_1.sh"
      destination = "/var/tmp/mysql_master_config_1.sh"
  }

  provisioner "file" {
      source = "./SCRIPTS/scalr_install_2.sh"
      destination = "/var/tmp/scalr_install_2.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /var/tmp/mysql_master_config_1.sh",
      "sudo /var/tmp/mysql_master_config_1.sh",
      "chmod +x /var/tmp/scalr_install_2.sh",
      "sudo /var/tmp/scalr_install_2.sh",
    ]
  }
}

# MySQL SLAVE

resource "null_resource" "configure_mysql_slave" {
  depends_on = [null_resource.configure_mysql_master_1]
  connection {
        host	= aws_instance.mysql_slave.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file(var.ssh_private_key_file)}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./SCRIPTS/scalr_install_2.sh"
      destination = "/var/tmp/scalr_install_2.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /var/tmp/scalr_install_2.sh",
      "sudo /var/tmp/scalr_install_2.sh",
    ]
  }
}

# MySQL MASTER 2


resource "null_resource" "configure_mysql_master_2" {
  depends_on = [null_resource.configure_mysql_slave]
  connection {
        host	= aws_instance.mysql_master.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file(var.ssh_private_key_file)}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./SCRIPTS/start_replication.sh"
      destination = "/var/tmp/start_replication.sh"
  }
/*
  provisioner "remote-exec" {
    inline = [
      "chmod +x /var/tmp/start_replication.sh",
      "sudo /var/tmp/start_replication.sh ${aws_instance.mysql_master.private_ip} ${aws_instance.mysql_slave.private_ip}",
    ]
  }
*/
}


# Worker

resource "null_resource" "configure_worker" {

  depends_on = ["null_resource.configure_mysql_master_2"]
  connection {
        host	= aws_instance.worker.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file(var.ssh_private_key_file)}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./SCRIPTS/scalr_install_2.sh"
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
        private_key = "${file(var.ssh_private_key_file)}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./SCRIPTS/scalr_install_2.sh"
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
        private_key = "${file(var.ssh_private_key_file)}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./SCRIPTS/scalr_install_2.sh"
      destination = "/var/tmp/scalr_install_2.sh"

  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /var/tmp/scalr_install_2.sh",
      "sudo /var/tmp/scalr_install_2.sh",
    ]
  }
}

# Proxy 2

resource "null_resource" "configure_proxy_2" {

  depends_on = ["null_resource.configure_worker"]
  connection {
        host	= aws_instance.proxy_2.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file(var.ssh_private_key_file)}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./SCRIPTS/scalr_install_2.sh"
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

  depends_on = [null_resource.configure_proxy_1, null_resource.configure_proxy_2, null_resource.configure_influxdb]
  connection {
        host	= aws_instance.proxy_1.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = "${file(var.ssh_private_key_file)}"
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./SCRIPTS/get_pass.sh"
      destination = "/var/tmp/get_pass.sh"

  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /var/tmp/get_pass.sh",
      "sudo /var/tmp/get_pass.sh",
    ]
  }

}

output "dns_name" {
  value = aws_elb.scalr_lb.dns_name
}
output "scalr_proxy_1_public_ip" {
  value = aws_instance.proxy_1.public_ip
}
output "scalr_proxy_1_private_ip" {
  value = aws_instance.proxy_1.private_ip
}
output "scalr_proxy_2_public_ip" {
  value = aws_instance.proxy_2.public_ip
}
output "scalr_proxy_2_private_ip" {
  value = aws_instance.proxy_2.private_ip
}
output "mysql_master_public_ip" {
  value = aws_instance.mysql_master.public_ip
}
output "mysql_master_private_ip" {
  value = aws_instance.mysql_master.private_ip
}
output "mysql_slave_public_ip" {
  value = aws_instance.mysql_slave.public_ip
}
output "mysql_slave_private_ip" {
  value = aws_instance.mysql_slave.private_ip
}
output "worker_public_ip" {
  value = aws_instance.worker.public_ip
}
output "worker_private_ip" {
  value = aws_instance.worker.private_ip
}
output "influxdb_public_ip" {
  value = aws_instance.influxdb.public_ip
}
output "influxdb_private_ip" {
  value = aws_instance.influxdb.private_ip
}
