# Домашнее задание
## Знакомство с облачной инфраструктурой Yandex.Cloud
Выполнены все основные и дополнительные пункты ДЗ <https://cdn.otus.ru/media/public/3a/37/HW_cloud_bastion.pptx__1-5522-3a373b.pdf>

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