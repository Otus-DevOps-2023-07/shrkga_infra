source "yandex" "ubuntu16" {
    service_account_key_file = "${var.service_account_key_file}"
    folder_id = "${var.folder_id}"
    source_image_family = "${var.source_image_family}"
    image_name = "reddit-app-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
    image_family = "reddit-base"
    ssh_username = "ubuntu"
    platform_id = "standard-v3"
    use_ipv4_nat = "true"
    disk_size_gb = "${var.disk_size_gb}"
}

build {
    sources = ["source.yandex.ubuntu16"]

    provisioner "shell" {
        inline = [
            "echo Waiting for apt-get to finish...",
            "a=1; while [ -n \"$(pgrep apt-get)\" ]; do echo $a; sleep 1s; a=$(expr $a + 1); done",
            "echo Done."
        ]
    }

    provisioner "shell" {
        name = "ruby"
        script = "./scripts/install_ruby.sh"
        execute_command = "sudo {{.Path}}"
    }
}

variable "folder_id" {
    type = string
    default = "b1glt5c0u97ip5ne26kt"
    // Sensitive vars are hidden from output as of Packer v1.6.5
    sensitive = true
}

variable "source_image_family" {
    type = string
    default = "ubuntu-1604-lts"
}

variable "service_account_key_file" {
    type = string
    default = "key.json"
    sensitive = true
}

variable "disk_size_gb" {
    type = number
    default = 5
}
