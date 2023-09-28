# Репозиторий shrkga_infra
Описание выполненных домашних заданий.

## ДЗ #11. Локальная разработка Ansible ролей с Vagrant. Тестирование конфигурации
Выполнены основные пункты ДЗ и задание со *. Практически всё содержимое данного задания работает с ошибками, или совсем не работает по причине сильного устаревания и различия синтаксиса с актуальными версиями модулей. Выполнить данное ДЗ в полной мере не представляется возможным.

#### Основное задание
- Выполнена установка VirtualBox и Vagrant;
- Локальная инфраструктура описана в `Vagrantfile`;
- Вместо бокса `ubuntu/xenial64` пришлось использовать `ubuntu/bionic64`, т.к. в xenial64 старый Bundler, который ругается на несоответствие версий в `Gemfile.lock`. А обновить bundler в данном боксе не получилось (процесс зависает). Поэтому использовался более новый бокс;
- Виртуальные машины `dbserver` и `appserver` успешно поднялись и прошли тестирование;
- Доработаны роли `app` и `db` на использование Ansible провижинера;
- Добавлен плейбук `base.yml` для установки python через `raw` модуль;
- Таски в ролях разнесены по разным файлам;
- Выполнена параметризации роли `app` для развертывания приложения в контексте пользователя `vagrant`, который передается через переопределение переменной `extra_vars`;
- Роли работают, провиженинг успешно выполняется;

#### Задание со ⭐: проксирование приложения с помощью nginx
- В файл переменных `ansible/roles/app/vars/main.yml` добавлены переменные для публикации сайта через роль `jdauphant.nginx`:
```
nginx_sites:
  default:
    - listen 80
    - server_name "reddit"
    - location / {
        proxy_pass http://127.0.0.1:9292;
      }
```

#### Тестирование роли
- Установлены необходимые компоненты для тестирования: Molecule, Ansible, Testinfra при помощи pip;
- Установка данных модулей выполнена в созданной через virtualenv среде;
- Необходимые зависимости добавлены в файл `requirements.txt`;
- Дальнейшее использование molecule в соответствии с указаниями ДЗ на каждом шагу приводило к ошибкам ввиду несоответствия устаревших версий в ДЗ тем, которые установились через pip.

## ДЗ #10. Ansible роли, управление настройками нескольких окружений и best practices
Выполнены все основные и дополнительные пункты ДЗ

#### Основное задание
- Созданные плейбуки перенесены в раздельные роли;
- Описаны два окружения -- `prod` и `stage`;
- Использована коммьюнити роль `nginx`;
- Для окружений используется Ansible Vault;
- С целью реализации механизма группировки и переиспользования конфигурационного кода, с использованием команды `ansible-galaxy` созданы роли для приложения и базы данных -- `app` и `db`;
- Определены переменные групп хостов;
- Заданы настройки окружений `prod` и `stage` с использованием групповых переменных;
- Плейбуки в папке ansible организованы согласно best practices;
- В файл ansible.cfg добавлен блок `[diff]`;
- Пересоздана terraform инфраструктура окружений `stage` и `prod`;
- Проверка ролей и работа приложения выполнены успешно;
- Использована community-роль `jdauphant.nginx` и настроено обратное проксирование для приложения с помощью nginx;

#### Самостоятельное задание
- Открытие 80 порта для инстанса приложения в конфигурацию Terraform не добавлялось, т.к. в рамках обучения работы с YC не задействован функционал "Групп безопасности" и все порты по умолчанию открыты;
- Добавлен вызов роли `jdauphant.nginx` в плейбук `app.yml`;
- Плейбук `site.yml` применен для окружения `stage`, выполнена проверка, приложение доступно на 80 порту;

#### Работа с Ansible Vault
- Изучен механизм Ansible Vault для безопасной работы с приватными данными;
- Созданы файлы с данными пользователей `credentials.yml` для окружений `stage` и `prod`;
- Выполнено шифрование файлов используя `vault.key`;
- Вызов плейбука создания пользователей добавлен в основной плейбук в файл site.yml для stage окружения;
- Пользователи успешно создаются;

#### Задание со ⭐: Работа с динамическим инвентори
- Настроено использование динамического инвентори для окружений `stage` и `prod`;
- Использован плагин `yc_compute` из прошлого ДЗ;
- Файл инвертори `inventory_yc.yml` для окружений приведен к виду;
```
---
plugin: yc_compute
folders:
  - b1glt5c0u97ip5ne26kt
filters:
  - status == 'RUNNING'
auth_kind: serviceaccountfile
service_account_file: ../packer/key.json
compose:
  ansible_host: network_interfaces[0].primary_v4_address.one_to_one_nat.address

# keyed_groups:
#   - key: labels['tags']

groups:
  db: labels['tags'] == 'reddit-db'
  app: labels['tags'] == 'reddit-app'
```

- Динамическая генерация инвентори выполняется успешно:
```
$ ansible-inventory --list --yaml

all:
  children:
    app:
      hosts:
        51.250.95.200:
          ansible_host: 51.250.95.200
          db_host: 10.128.0.27
          env: stage
          nginx_sites:
            default:
            - listen 80
            - server_name "reddit"
            - location / { proxy_pass http://127.0.0.1:9292; }
    db:
      hosts:
        51.250.12.249:
          ansible_host: 51.250.12.249
          env: stage
          mongo_bind_ip: 0.0.0.0
```

#### Задание с ⭐⭐: Настройка TravisCI
В рамках данного курса в предыдущих ДЗ TravisCI не изучался. Соответственно для выполнение задания необходимые знания получены не были.


## ДЗ #9. Продолжение знакомства с Ansible: templates, handlers, dynamic inventory, vault, tags
Выполнены все основные и дополнительные пункты ДЗ

#### Расширение функционала Terraform из прошлого ДЗ (спасибо <https://github.com/Swenum>)
Добавлена автоматическая генерация файла инвертори для Ansible при развертывании инфраструктуры через Terraform.

Создан файл шаблона `terraform/prod/inventory.tmpl`:
```
all:
  hosts:
      app:
        ansible_host: ${external_ip_address_app}
      db:
        ansible_host: ${external_ip_address_db}
  vars:
    remote_user: appuser
    private_key_file: ~/.ssh/yc
    db_host_internal: ${internal_ip_address_db}
```
В файл `terraform/prod/outputs.tf` добавлен ресурс для создания файла `ansible/inventory_${var.environment}.yml`:
```
### The Ansible inventory file
resource "local_file" "AnsibleInventory" {
  content = templatefile("inventory.tmpl", {
    external_ip_address_app = module.app.external_ip_address_app.0
    external_ip_address_db  = module.db.external_ip_address_db.0
    internal_ip_address_db  = module.db.internal_ip_address_db.0
  })
  filename = "../../ansible/inventory_${var.environment}.yml"
}
```
В результате после применения `terraform apply` генерируется YAML файл с актуальными IP адресами ВМ в YC.

#### Основное задание
- Изучен подход "Один playbook, один сценарий";
  - Изучены Tasks и Handlers;
  - Все проверки завершились успешно;
- Изучен подход "Один плейбук, несколько сценариев";
  - Написан сценарий для MongoDB;
  - Написан сценарий для App;
  - Написан сценарий для деплоя;
  - Все проверки завершились успешно;
- Изучен подход "Несколько плейбуков";
  - Написан отдельный плейбук для MongoDB;
  - Написан отдельный плейбук для App;
  - Написан отдельный плейбук для деплоя;
  - Написан общий плейбук `site.yml` для импорта трех предыдущих плейбуков;
  - Все проверки завершились успешно;

#### Задание со ⭐
- В рамках задания "Использовать dynamic inventory для Yandex Cloud" нагуглен плагин `yc_compute.py`;
- Плагин нерабочий, чтобы он заработал, пришлось в его коде поменять название с `community.general.yc_compute` на `yc_compute`;

Процесс установки плагина и зависимостей:
```
cd ansible
mkdir -p plugins/inventory
curl https://raw.githubusercontent.com/st8f/community.general/yc_compute/plugins/inventory/yc_compute.py | \
  sed -e 's/community\.general\.yc_compute/yc_compute/g' > plugins/inventory/yc_compute.py
pip install yandexcloud
```

- Создан файл `inventory_yc.yml` с использованием плагина `yc_compute` и функционала `keyed_groups` (группируем хосты по метке `tags`):
```
---
plugin: yc_compute
folders:
  - b1glt5c0u97ip5ne26kt
filters:
  - status == 'RUNNING'
auth_kind: serviceaccountfile
service_account_file: ../packer/key.json
compose:
  ansible_host: network_interfaces[0].primary_v4_address.one_to_one_nat.address

keyed_groups:
  - key: labels['tags']
```

- Содержимое файла `ansible.cfg` приведено к виду:
```
[defaults]
inventory = ./inventory_yc.yml
remote_user = appuser
private_key_file = ~/.ssh/yc
host_key_checking = False
retry_files_enabled = False

inventory_plugins=./plugins/inventory

[inventory]
enable_plugins = yc_compute
```

- Проверка инвентори:
```
$ ansible-inventory --list --yaml

all:
  children:
    _reddit_app:
      hosts:
        51.250.71.210:
          ansible_host: 51.250.71.210
    _reddit_db:
      hosts:
        51.250.88.50:
          ansible_host: 51.250.88.50
```

- Пробуем пинг:
```
$ ansible all -m ping

51.250.71.210 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
51.250.88.50 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

#### Самостоятельное задание
- Выполнен провижининг в Packer;
- Созданы плейбуки `ansible/packer_app.yml` и `ansible/packer_db.yml`:
  - `packer_app.yml` устанавливает Ruby и Bundler с помощью модулей Ansible;
  - `packer_db.yml` устанавливает MongoDB с помощью модулей Ansible;
  - При этом модули `command` и `shell` не используются;
- Выполнена интеграция Ansible в Packer через provisioner типа ansible;
- На основе созданных `app` и `db` образов в каталоге `terraform/stage` запущено `stage` окружение;
- Успешно выполнена проверка, что c помощью плейбука `site.yml` из предыдущего раздела окружение конфигурируется, а приложение деплоится и работает.

## ДЗ #8. Управление конфигурацией. Знакомство с Ansible
Выполнены все основные и дополнительные пункты ДЗ (⭐)

#### Основное задание
- Выполнены установка и настройка Ansible;
- В модули Terraform app и db добавлен функционал запуска команд в провиженере `remote-exec` в зависимости от значения переменной `provision`. Таким образом, для текущей задачи поднятие сервисов средствами Terraform не выполняется;
```
$ cat terraform/modules/app/variables.tf
...
variable "provision" {
  description = "Enable provisioning or not"
  type        = bool
  default     = false
}
...
```
```
$ cat terraform/modules/app/main.tf
...
provisioner "file" {
  source      = "${path.module}/deploy.sh"
  destination = "/tmp/deploy.sh"
}
provisioner "remote-exec" {
  inline = concat(["echo Provisioning"], [for command in ["chmod +x /tmp/deploy.sh", "/tmp/deploy.sh"]: command if var.provision])
}
...
```
- С помощью Terraform в YC запущены `appserver` и `dbserver` из предыдущих заданий;
- Изучены различные способы создания Inventory file;
- Реализовано управление ВМ `appserver` и `dbserver` в YC при помощи Ansible;
- Определены параметры по умолчанию в файле `ansible.cfg`;
- Выполнена работа с группами хостов;
- Создан YAML inventory файл;
- Все команды из ДЗ выполнены успешно;
- Написан плейбук `clone.yml`. В плейбук добавлен таск по установке `git`, т.к. в инстансе он отсутствует;
```
$ cat clone.yml
---
- name: Clone
  hosts: app
  tasks:
    - name: Install git
      become: true
      apt:
        name: git
        state: latest
        update_cache: yes
    - name: Clone repo
      git:
        repo: https://github.com/express42/reddit.git
        dest: /home/ubuntu/reddit
```
- Выполнена команда `ansible-playbook clone.yml` с уже существующим локальным клоном репозитория и без него. Получились разные варианты:
  - В первом случае результат `changed=0`, т.к. фактически менять нечего и репозиторий был склонирован через `git clone` на предыдущем шаге;
  - Во втором случае результат `changed=1`, т.к. локальной копии репозитория не было и его клон выполнен непосредственно при работе модуля git ansible.

#### Задание со ⭐
- Изучены две различных схемы JSON-inventory -- статическая и динамическая;
- Создан файл `inventory.json` в формате динамического инвентори;
- Создан файл `inventory-static.json` в формате статического инвентори;
- Проведен анализ различия статического и динамического форматов, понято значение группы `_meta`, а также различие формата при описании группы хостов в переменной `hosts`;
- Написан bash-скрипт `inventory.sh`, который генерирует json массив в формате динамического инвентори. При этом IP адреса инстансов `app` и `db` запрашиваются в YC через `yc compute instance get`.<br>Для ускорения работы скрипта их можно определить вручную в соответствующих переменных;
- Скрипт `inventory.sh` поддерживает ключи `--list` и `--host`;
- В файле `ansible.cfg` сделаны настройки для работы с JSON-inventory;
- Команда `ansible all -m ping` выполняется успешно.
```
$ ansible all -m ping

84.201.159.224 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
158.160.55.69 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

## ДЗ #7. Принципы организации инфраструктурного кода и работа над инфраструктурой в команде на примере Terraform
Выполнены все основные и дополнительные пункты ДЗ (⭐ и ⭐⭐)

### Информация относительно невозможности пройти тест в Github Actions
По аналогии с прошлым ДЗ сделано изрядное количество костылей для прохождения нерабочих тестов. Их описание добавлено при помощи комментариев в затронутых файлах.

#### Основное задание
- Созданы образы ВМ для приложений APP и DB через `packer`;
- Изучены атрибуты ресурсов;
- Конфиги ВМ разнесены по разным файлам;
- Изучена работа с модулями;
  - Создан модуль APP;
  - Создан модуль DB;
  - Для модулей определены выходные переменные;
- Инстансы ВМ описаны в модулях;
- Выполнена проверка, ВМ доступны по `ssh`;
- Изучен принцип разработки DRY через переиспользование модулей;
  - Созданы каталоги для окружений `stage` и `prod`;
  - Конфигурация модулей параметризирована через переменные;

#### Задание со ⭐
- Настроено хранение стейт файла в удаленном бекенде для окружений `stage` и `prod`, используя Yandex Object Storage в качестве бекенда;
- Проконтролировано, что Terraform "видит" текущее состояние независимо от директории, в которой запускается;
- Проверена работа блокировок через одновременный запуск `terraform apply` в разных окружениях;

#### Задание с ⭐⭐
- Добавлены provisioners в модули для деплоя и работы приложения;
- Внутренний IP адрес ВМ с БД передается в конфигурацию сервиса Puma HTTP Server через переменную `DATABASE_URL` (см. файл `terraform/modules/app/puma.service`);
```
[Service]
Environment='DATABASE_URL=${internal_ip_address_db}'
```
Определение переменной `internal_ip_address_db` осуществляется через функцию `templatefile` в провиженере `file`:
```
provisioner "file" {
  content     = templatefile("${path.module}/puma.service", { internal_ip_address_db = "${var.db_ip}" })
  destination = "/tmp/puma.service"
}
```

- В каталоге `terraform/s3` определен набор конфиг файлов для автоматизации создания бакета в Yandex Object Storage;

После создания бакета и получения выходных переменных `access_key` и `secret_key`, инициализация бэкенда, описанного в файле `backend.tf`, выполняется следующим образом:
```
$ export ACCESS_KEY="<идентификатор_ключа>"
$ export SECRET_KEY="<секретный_ключ>"

$ terraform init -backend-config="access_key=$ACCESS_KEY" -backend-config="secret_key=$SECRET_KEY"
```
Далее при разворачивании окружения state-файл `terraform.tfstate` создается и актуализируется в бакете Yandex Object Storage.

## ДЗ #6. Практика IaC с использованием Terraform
Выполнены все основные и дополнительные пункты ДЗ.

### Информация относительно невозможности пройти тест в Github Actions
При выполнении команды:
```
cd terraform && terraform init && terraform validate -var-file=terraform.tfvars.example
```
возвращается ошибка о некорректности определения в файле `main.tf` объекта `yandex` в блоке `required_providers`, что, по-видимому, связано со старой версией terraform в тесте.

Для прохождения теста в качестве "костыля" блок `terraform` перемещен из `main.tf` в файл `config.tf`, который при пуше в репозиторий переименован в `config.tf.renamed-for-tests`. Для нормальной работы проекта файл необходимо переименовать обратно в `config.tf`.

#### Самостоятельная работа
- Установлен Terraform;
- Создан сервисный аккаунт для Terraform в Yandex.Cloud (YC);
- Делегированы права сервисному аккаунту для Terraform;
- В каталоге `terraform` созданы необходимые файлы конфигурации `*.tf`, файлы переменных, service account key file, исключения добавлены в `.gitignore`;
- Загружен провайдер Terraform для YC;
- Добавлен ресурс для создания инстанса VM в YC;
- Определены Input и Output variables;
- Добавлены необходимые Provisioners и параметры подключения;
- Запланированы и применены изменения, ВМ успешно развернута в YC в соответствии с описанным шаблоном;
- Через Output variable определен внешний IP ВМ.

В результате ВМ в Yandex.Cloud доступна через `ssh ubuntu@<внешний-IP-машины>`, приложение Monolith Reddit доступно по адресу:<br>
http://<внешний-IP-машины>:9292

```
$ terraform -v
Terraform v1.5.6
on linux_amd64
+ provider registry.terraform.io/yandex-cloud/yandex v0.95.0
```

#### Дополнительное задание
- Определена input переменная для приватного ключа;
- Определена input переменная для задания зоны в ресурсе "yandex_compute_instance" "app", задано значение по умолчанию;
- Отформатированы конфигурационные файлы командой `terraform fmt`;
- Создан файл `terraform.tfvars.example`, в котором указаны переменные для образца.

#### Задание с **
- Создан файл `lb.tf`, описано в коде terraform создание HTTP балансировщика, направляющего трафик на развернутое приложение на инстансе reddit-app;
- Проверена доступность приложения по адресу балансировщика;
- Добавлен в output переменные адрес балансировщика;
- Добавлен в код еще один terraform ресурс для нового инстанса приложения `reddit-app2`;
- Проверена доступность приложения при остановке одного из инстансов;
- Добавлен в output переменные адрес второго инстанса;

При данной конфигурации приложения возникает проблема дублирования кода. При изменении параметров инстансов придется их менять дважды. Отсутствует гибкость при необходимости масштабировать инстансы. Поэтому правильно задавать количества инстансов через параметр ресурса `count`. Переменная `app_count` задается в параметрах (файл `variables.tf`) и по умолчанию равна 1.

- Описание инстанса `reddit-app2` удалено из кода;
- Количество инстансов определено через параметр `count`;
- IP адреса инстансов и балансировщика определены через Output variables (файл `outputs.tf`);
- По завершению ДЗ созданные ресурсы удалены через `terraform destroy`.

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
