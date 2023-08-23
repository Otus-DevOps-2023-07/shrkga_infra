# Используем CLI для созданиā инстанса, для проверки корректности работы CLI после настройки
# https://gist.githubusercontent.com/mrgreyves/cfdde1c6f3071ad3e2eaa89eccffedd3/raw/da753c5c01cd242232ff45e8a5806bf116aa8488/instance-create-script

yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory=4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
  --network-interface subnet-name=default-ru-central1-b,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 \
  --ssh-key ~/.ssh/appuser.pub

# Устанавливаем Ruby

ssh yc-user@158.160.13.198

sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential

# Проверяем Ruby и Bundler

ruby -v
bundler -v

# Устанавливаем MongoDB

sudo apt update
sudo apt install mongodb -y

systemctl status mongodb

sudo systemctl start mongodb
sudo systemctl enable mongodb

# Деплой приложения

sudo apt install git -y
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install

puma -d
ps aux | grep puma

# http://158.160.13.198:9292/
