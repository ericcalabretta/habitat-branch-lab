resource "aws_instance" "cache_permanent_peer" {
  connection {
    user        = "${var.aws_ami_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
  }

  ami                         = "${data.aws_ami.centos.id}"
  instance_type               = "${var.test_server_instance_type}"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.habitat_branch_lab_subnet.id}"
  vpc_security_group_ids      = ["${aws_security_group.habitat_branch_lab.id}", "${aws_security_group.habitat_supervisor.id}"]
  associate_public_ip_address = true

  tags {
    Name          = "cache_permanent_peer_${random_id.instance_id.hex}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "file" {
    content     = "${data.template_file.install_hab.rendered}"
    destination = "/tmp/install_hab.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.cache_permanent_peer.rendered}"
    destination = "/home/${var.aws_ami_user}/hab-sup.service"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname cache-permanent-peer",
      "sudo groupadd hab",
      "sudo adduser hab -g hab",
      "chmod +x /tmp/install_hab.sh",
      "sudo /tmp/install_hab.sh",
      "sudo mv /home/${var.aws_ami_user}/hab-sup.service /etc/systemd/system/hab-sup.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start hab-sup",
      "sudo systemctl enable hab-sup",
      "sleep 45",
      "sudo hab svc load eric/sample --group ${var.group} --strategy at-once",
      "sudo hab svc load eric/nginx --group ${var.group} --strategy at-once",

    ]
  }
}

////////////////////////////////
// Templates

data "template_file" "cache_permanent_peer" {
  template = "${file("${path.module}/../templates/hab-sup.service")}"

  vars {
    flags = "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --permanent-peer"
  }
}

data "template_file" "sup_service" {
  template = "${file("${path.module}/../templates/hab-sup.service")}"

  vars {
    flags = "--auto-update --peer ${aws_instance.cache_permanent_peer.private_ip} --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631"
  }
}

data "template_file" "install_hab" {
  template = "${file("${path.module}/../templates/install-hab.sh")}"
}

data "template_file" "hab_windows_install" {
  template = "${file("${path.module}/../templates/hab_windows_install.ps1")}"

  vars {
    flags = "--auto-update --peer ${aws_instance.cache_permanent_peer.private_ip} --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631"
  }
}


////////////////////////////////
// simulated display_system

resource "aws_instance" "display_system" {
    connection {
    type     = "winrm"
    user     = "Administrator"
    password = "${var.windows_admin_password}"

    # set from default of 5m to 10m to avoid winrm timeout
    timeout = "10m"
  }
  ami                         = "${data.aws_ami.windows_node.id}"
  instance_type               = "t2.large"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.habitat_branch_lab_subnet.id}"
  vpc_security_group_ids      = ["${aws_security_group.habitat_branch_lab.id}"]
  associate_public_ip_address = true
  get_password_data           = true
  count                       = "${var.count}"

  root_block_device {
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }

   user_data = <<EOF
<script>
  winrm quickconfig -q & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"}
</script>
<powershell>
  netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
  # Set Administrator password
  $admin = [adsi]("WinNT://./administrator, user")
  $admin.psbase.invoke("SetPassword", "${var.windows_admin_password}")
</powershell>
EOF

  tags {
    Name          = "${var.tag_contact}-${var.tag_customer}-habitat-branch-${count.index}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

 provisioner "file" {
    content     = "${data.template_file.hab_windows_install.rendered}"
    destination = "c:/hab_windows_install.ps1"
  }

// provisioner "remote-exec" {
//   connection = {
//     type    = "winrm"
//     password  = "${var.windows_admin_password}"
//     agent     = "false"
//     insecure  = true
//     https     = false
//   }
//   inline = [
//     "powershell.exe C:/hab_windows_install.ps1",
//     // "powershell.exe hab svc load eric/contosouniversity --channel stable --strategy at-once",
//   ]
// }
}

resource "aws_instance" "point_of_sale" {
    connection {
    type     = "winrm"
    user     = "Administrator"
    password = "${var.windows_admin_password}"

    # set from default of 5m to 10m to avoid winrm timeout
    timeout = "10m"
  }
  ami                         = "${data.aws_ami.windows_node.id}"
  instance_type               = "t2.large"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.habitat_branch_lab_subnet.id}"
  vpc_security_group_ids      = ["${aws_security_group.habitat_branch_lab.id}"]
  associate_public_ip_address = true
  get_password_data           = true
  count                       = "${var.count}"

  root_block_device {
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }

   user_data = <<EOF
<script>
  winrm quickconfig -q & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"}
</script>
<powershell>
  netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
  # Set Administrator password
  $admin = [adsi]("WinNT://./administrator, user")
  $admin.psbase.invoke("SetPassword", "${var.windows_admin_password}")
</powershell>
EOF

  tags {
    Name          = "${var.tag_contact}-${var.tag_customer}-habitat-branch-${count.index}"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

 provisioner "file" {
    content     = "${data.template_file.hab_windows_install.rendered}"
    destination = "c:/hab_windows_install.ps1"
  }

// provisioner "remote-exec" {
//   connection = {
//     type    = "winrm"
//     password  = "${var.windows_admin_password}"
//     agent     = "false"
//     insecure  = true
//     https     = false
//   }
//   inline = [
//     "powershell.exe C:/hab_windows_install.ps1",
//     // "powershell.exe hab svc load eric/contosouniversity --channel stable --strategy at-once",
//   ]
// }
}