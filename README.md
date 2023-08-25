# Репозиторий shrkga_infra
Описание выполненных домашних заданий.

## ДЗ #5. Сборка образов VM при помощи Packer
Выполнены все основные и дополнительные пункты ДЗ.

#### Самостоятельная работа
- Установлен Packer;
- Создан сервисный аккаунт для Packer в Yandex.Cloud;
- Делегированы права сервисному аккаунту для Packer;
- Создан service account key file, добавлен в `.gitignore`;
- Создан файл-шаблон Packer;
- Создан файл конфигурации Builder, добавлены Provisioners;
- Созданы скрипты для Provisioners;
- Проведена валидация, устранена ошибка с IPv4;
- Создан образ ВМ, на базе образа создана ВМ;
- Внутри ВМ установлено приложение Monolith Reddit;
- Проверена работа приложения через открытие адреса http://<внешний-IP-машины>:9292
- Файлы конфигурации созданы в форматах `.hcp` и `.json`. Файлы с переменными добавлены в `.gitignore`;
```
$ packer -v
1.9.4

$ ls packer/*.hcl
packer/config.pkr.hcl  packer/ubuntu16.pkr.hcl  packer/variables.pkr.hcl

$ ls packer/*.json
packer/immutable.json  packer/key.json  packer/ubuntu16.json  packer/variables.json
```

#### Дополнительное задание
- Параметризирован созданный шаблон. Набор параметров включает:
  - ID каталога;
  - ID source-образа;
  - Путь к `service_account_key_file`;
  - Размер диска `disk_size_gb`;
  - Другие опции билдера.
- С целью практики подхода к управлению инфраструктурой Immutable infrastructure, построен bake-образ на базе шаблона `immutable.json`:
  - `image_family` у получившегося образа задан `reddit-full`;
  - В папке `packer/files` размещен файл конфигурации сервиса `puma.service` с целью использования `systemd unit` для запуска приложения при старте инстанса.

```
$ cat packer/files/puma.service

[Unit]
Description=Puma
After=network.target

[Service]
Type=simple
WorkingDirectory=/server/reddit
ExecStart=/usr/local/bin/puma
Restart=always

[Install]
WantedBy=multi-user.target
```

- Выполнена автоматизация создания ВМ:
  - В папке `config-scripts` создан скрипт `create-reddit-vm.sh`, который создает ВМ с помощью Yandex.Cloud CLI.

```
$ cat config-scripts/create-reddit-vm.sh

#!/bin/bash

set -e

FOLDER_ID=$(yc config list | grep folder-id | awk '{print $2}')

yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory 2 \
  --cores 2 \
  --core-fraction 20 \
  --preemptible \
  --create-boot-disk image-folder-id=${FOLDER_ID},image-family=reddit-full,size=10GB \
  --network-interface subnet-name=default-ru-central1-b,nat-ip-version=ipv4 \
  --ssh-key ~/.ssh/appuser.pub
  ```

В результате ВМ в Yandex.Cloud доступна через `ssh appuser@<внешний-IP-машины>`, приложение Monolith Reddit доступно по адресу:<br>
http://<внешний-IP-машины>:9292

## ДЗ #4. Деплой тестового приложения
Выполнены все основные и дополнительные пункты ДЗ.

### Данные для подключения к Monolith Reddit
```
testapp_IP = 158.160.17.174
testapp_port = 9292
```

#### Самостоятельная работа
- Скрипт `install_ruby.sh` содержит команды по установке Ruby;
- Скрипт `install_mongodb.sh` содержит команды по установке MongoDB;
- Скрипт `deploy.sh` содержит команды скачивания кода, установки зависимостей через bundler и запуск приложения;
- Скрипт `reddit-vm.sh` содержит команду для автоматического развертывания с использованием cloud-config файла `reddit-metadata.yaml`.

#### Дополнительное задание
Создан файл с метаданными для автоматизации деплоя приложения Monolith Reddit при помощи Cloud-init. Пример файла `reddit-metadata.yaml` ниже. Вместо <YOUR_PUBLIC_KEY> нужно подставить ваш публичный ключ.
```
#cloud-config

ssh_pwauth: false
users:
  - name: yc-user
    gecos: YandexCloud User
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - "<YOUR_PUBLIC_KEY>"

package_update: true
package_upgrade: true
packages:
  - mongodb
  - ruby-full
  - ruby-bundler
  - build-essential
  - git

runcmd:
  - systemctl start mongodb
  - systemctl enable mongodb
  - cd /home/yc-user
  - git clone -b monolith https://github.com/express42/reddit.git
  - cd reddit && bundle install
  - puma -d
```

ВМ разворачивается в Yandex.Cloud при помощи CLI команды (скрипт `reddit-vm.sh`):
```
yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory=4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
  --network-interface subnet-name=default-ru-central1-b,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 \
  --metadata-from-file user-data=reddit-metadata.yaml
```

## ДЗ #3. Знакомство с облачной инфраструктурой Yandex.Cloud
Выполнены все основные и дополнительные пункты ДЗ.

### Способ подключения к someinternalhost в одну команду с рабочего устройства
Используется ключ `-J [user@]host[:port]`

```
ssh -A -J appuser@84.252.128.139 appuser@someinternalhost
```

### Способ подключения к someinternalhost с помощью алиаса с рабочего устройства
В файле `~/.ssh/config` добавляем следующие параметры:
```
# Yandex Cloud bastion host
Host yc-bastion
  HostName 84.252.128.139
  User appuser
  IdentityFile ~/.ssh/appuser
  ForwardAgent yes

# some internal host
Host someinternalhost
  User appuser
  ProxyJump yc-bastion
```

В результате подключение к someinternalhost происходит по команде
```
ssh someinternalhost
```

### На Bastion host установлен Pritunl VPN Server
```
bastion_IP = 84.252.128.139
someinternalhost_IP = 10.128.0.10
```

Скрипт установки взят с официального сайта, т.к. скрипт по ссылке в ДЗ содержит ошибку и в целом выглядит устаревшим. Актуальный скрипт взят отсюда:<br>
<https://docs.pritunl.com/docs/installation#other-providers-ubuntu-2204>

С помощью сервиса nip.io реализовано использование валидного Let's Encrypt сертификата для панели управления VPN сервера по адресу <https://54fc808b.nip.io/>

После установки OpenVPN подключения внутренний хост подключается напрямую при помощи команды
```
ssh appuser@10.128.0.10
```
