#!/bin/bash

if [[ $1 == "--list" ]]; then
    # apphost=$(yc compute instance get --name reddit-app-prod-0 --format=json | jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address')
    # dbhost=$(yc compute instance get --name reddit-db-prod-0 --format=json | jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address')
    apphost='51.250.70.24'
    dbhost='158.160.122.226'

    cat <<EOT
{
    "_meta": {
        "hostvars": {}
    },
    "app": {
        "hosts": ["${apphost}"],
        "vars": {
            "ansible_user": "ubuntu",
            "ansible_private_key_file": "~/.ssh/yc"
        }
    },
    "db": {
        "hosts": ["${dbhost}"],
        "vars": {
            "ansible_user": "ubuntu",
            "ansible_private_key_file": "~/.ssh/yc"
        }
    }
}
EOT
elif [[ $1 == "--host" ]]; then
    echo '{"_meta": {"hostvars": {}}}' | jq -M
else
    echo '{}'
fi
