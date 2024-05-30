variable "app_name" {
  type    = string
  default = "lamp"
}

variable "app_version" {
  type    = string
  default = "latest"
}

variable "hcloud_image" {
  type    = string
  default = "ubuntu-24.04"
}

variable "apt_packages" {
  type    = string
  default = "apache2 mysql-server libapache2-mod-php php php-mysql php-cli python3-certbot-apache certbot perl software-properties-common"
}

build {
  sources = ["source.hcloud.autogenerated_1"]

  provisioner "shell" {
    inline = ["cloud-init status --wait --long"]
    valid_exit_codes = [0, 2]
  }

  provisioner "file" {
    destination = "/etc/"
    source      = "apps/hetzner/lamp/files/etc/"
  }

  provisioner "file" {
    destination = "/opt/"
    source      = "apps/hetzner/lamp/files/opt/"
  }

  provisioner "file" {
    destination = "/var/"
    source      = "apps/hetzner/lamp/files/var/"
  }

  provisioner "file" {
    destination = "/var/www/"
    source      = "apps/shared/www/"
  }

  provisioner "file" {
    destination = "/var/www/html/assets/"
    source      = "apps/hetzner/lamp/images/"
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive", "LC_ALL=C", "LANG=en_US.UTF-8", "LC_CTYPE=en_US.UTF-8"]
    scripts          = ["apps/shared/scripts/apt-upgrade.sh"]
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive", "LC_ALL=C", "LANG=en_US.UTF-8", "LC_CTYPE=en_US.UTF-8"]
    inline           = ["apt -qqy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install ${var.apt_packages}"]
  }

  provisioner "shell" {
    environment_vars = ["application_name=${var.app_name}", "application_version=${var.app_version}", "DEBIAN_FRONTEND=noninteractive", "LC_ALL=C", "LANG=en_US.UTF-8", "LC_CTYPE=en_US.UTF-8"]
    scripts          = ["apps/shared/scripts/apt-upgrade.sh", "apps/hetzner/lamp/scripts/lamp-install.sh", "apps/shared/scripts/cleanup.sh"]
  }

}
