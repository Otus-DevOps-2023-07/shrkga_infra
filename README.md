# Репозиторий shrkga_infra
Описание выполненных домашних заданий.

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
