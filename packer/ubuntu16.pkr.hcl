source "yandex" "ubuntu16" {
    service_account_key_file = "${var.service_account_key_file}"
    folder_id = "${var.folder_id}"
    source_image_family = "${var.source_image_family}"
    image_name = "reddit-base-${formatdate("YYYY-MM-DD-hhmmss", timestamp())}"
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

    provisioner "shell" {
        name = "mongodb"
        script = "./scripts/install_mongodb.sh"
        execute_command = "sudo {{.Path}}"
    }
}
