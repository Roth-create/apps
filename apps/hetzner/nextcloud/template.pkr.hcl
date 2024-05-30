variable "app_name" {
  type    = string
  default = "nextcloud"
}

variable "app_version" {
  type    = string
  default = "28.0.5"
}

variable "app_checksum" {
  type    = string
  default = "d32ce0769b455afad5bbb680e53063907c7d8005950c0ac286559e5a40d3343d"
}

variable "hcloud_image" {
  type    = string
  default = "ubuntu-24.04"
}

variable "apt_packages" {
  type    = string
  default = "apache2 php libapache2-mod-php php-gd php-mysql php-curl php-mbstring php-intl php-gmp php-bcmath php-imagick php-xml php-zip mysql-server python3-certbot-apache software-properties-common unzip"
}

build {
  sources = ["source.hcloud.autogenerated_1"]

  provisioner "shell" {
    inline = ["cloud-init status --wait --long"]
    valid_exit_codes = [0, 2]
  }

  provisioner "file" {
    destination = "/etc/"
    source      = "apps/hetzner/nextcloud/files/etc/"
  }

  provisioner "file" {
    destination = "/opt/"
    source      = "apps/hetzner/nextcloud/files/opt/"
  }

  provisioner "file" {
    destination = "/var/"
    source      = "apps/hetzner/nextcloud/files/var/"
  }

  provisioner "file" {
    destination = "/var/www/"
    source      = "apps/shared/www/"
  }

  provisioner "file" {
    destination = "/var/www/html/assets/"
    source      = "apps/hetzner/nextcloud/images/"
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
    environment_vars = ["application_name=${var.app_name}", "application_version=${var.app_version}", "application_checksum=${var.app_checksum}", "DEBIAN_FRONTEND=noninteractive", "LC_ALL=C", "LANG=en_US.UTF-8", "LC_CTYPE=en_US.UTF-8"]
    scripts          = ["apps/shared/scripts/apt-upgrade.sh", "apps/hetzner/nextcloud/scripts/nextcloud-install.sh", "apps/shared/scripts/cleanup.sh"]
  }

}
