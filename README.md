# 2048-game CI/CD
Содержимое данного репозитория позволит Вам в автоматическом режиме собрать образ ***Docker-container*** и разместить его в ***Container Registry*** [GitLab,](https://about.gitlab.com/) а так же подготовить виртуальную машину в ***Yandex Cloud*** для сборки образа.

Для работы Вам понадобится операционная система [Ubunu](https://ubuntu.com/) или [WSL](https://learn.microsoft.com/ru-ru/windows/wsl/install) нa ***Windows***, а так же а так же аккаунты в [Yandex Cloud](https://console.cloud.yandex.ru/) и [GitLab.](https://about.gitlab.com/) 

# Начнем
![Oh shit](https://darkstalker.ru/wp-content/uploads/b/8/3/b836197c6ac8c466c1befe0d57938929.png)

Создайте копию репозитория в домашнем каталоге пользователя `/home/<user>/`, введя команду:
```
git clone https://github.com/protasov-kun/2048-game
```

Убедитесь, что у вас есть аккаунт на [GitLab](https://about.gitlab.com/) и создайте в нем проект ***2048-game***.

Надеюсь у вас есть [Personal Access Token](https://gitlab.com/-/user_settings/personal_access_tokens)? Он нам пригадится в будущем.

Синхронизируте ваш рабочий каталог `/home/<user>/2048-game` с репозиторием [GitLab:](https://about.gitlab.com/)
```
git remote remove github
git remote add gitlab https://gitlab.com/<user>/2048-game.git
```

# Инициализируем Terraform и запустим виртуальную машину

Для начала следует создать каталог, сервисный аккаунт и назначить роли в соответствии с [документацией YC,](https://cloud.yandex.ru/ru/docs/tutorials/infrastructure-management/terraform-quickstart#before-you-begin)а так же создать авторизованный ключ для сервисного аккаунта. *В нашем случае авторизованный ключ хранится в домашнем каталоге пользователя* `/home/<user>/`.

Установить пакет *terraform*
```
sudo snap install --classic terrafofm
```
Создайте в домашнем каталоге пользователя файл `/home/<user>/.terraformrc` с содержанием:
```
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```

Создайте пару ключей SSH `ssh-keygen -t ed25519`

В файле `/home/<user>/2048-game/main.tf` отредактируйте директиву:
```
locals {
  folder_id = "b1g27pnvvlliqavhq6d8"
  cloud_id  = "b1gh58hlo9our1iocsva"
}
```
указав идентификаторы вашего каталога и платежного аккаунта.

##### Если вы сохранили файл авторизованного ключа сервисного аккаунта Yandex Cloud не в домашнем каталоге пользователя
тогда в файле `/home/<user>/2048-game/main.tf` в директиве:
```
provider "yandex" {
  service_account_key_file = "${file("~/authorized_key.json")}"
  cloud_id                 = local.cloud_id
  folder_id                = local.folder_id
}
```
отредактируйте строку `service_account_key_file =....`, указав расположение файла.

##### Далее введите команды:
```
terraform init && terraform apply
```
![run](https://www.daidegasforum.com/images1/821/aston-martin-one-77-drift-slide-gif.gif)


# Теперь приступим к жесткому DevOps

Установите необходимое ПО:
```
sudo apt update && sudo apt install ansible docker.io
sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64
sudo chmod +x /usr/local/bin/gitlab-runner
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start
```

Позвольте новым пользователям вашей системы пользоваться вашими файлами:
```
sudo usermod -aG gitlab-runner $USER && sudo usermod -aG docker $USER
```


В файле `/home/gitlab-runner/.bash_logout` закоментируйте директиву:
```
#if [ "$SHLVL" = 1 ]; then
#    [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
#fi
```
## Давайте билдить

Здесь как раз нам и пригодится тот самый [Personal Access Token](https://gitlab.com/-/user_settings/personal_access_tokens) в качестве пароля к учетке, когда это потребуется.

Чтобв в ходе пайплайна докер мог подключаться к ***Container Registry*** создайте переменную в настройках [GitLab](https://about.gitlab.com/) `https://gitlab.com/<user>/2048-game/-/settings/ci_cd` в разделе `Variables` c:
Key: ACCESS_TOKEN
Value: [Personal Access Token](https://gitlab.com/-/user_settings/personal_access_tokens)

Зарегистрируйте gitlab-genner:
```
sudo gitlab-runner register
```
в качестве URL, укмжате `https://gitlab.com/`, регистрационный токен для ранера можно найти сдесь `https://gitlab.com/<user>/2048-game/-/settings/ci_cd`, добавьте тэги `buils,deploy,latest`.

Убедитесь, что вы находитесь в рабочем каталоге `/home/<user>/2048-game/`.

Введите команду:
```
git add .
```

Файл пайплайна `/home/<user>/2048-game/.gitlab-ci.yml` содержит команду, кторая вычлиняет цифры и точки из `commit message` и тэжит результатом образ.

Поэтому рекомндую коммит делать примерно так:
```
git commit -m "sdelal priemlemo, image version 1.0"
```

Пушим:
```
git push gitlab master
```

Пайплайн добавит в ***Container Registry*** две версии образа:
1. 1.0
2. latest

## А что насчет виртуальной машины?

Тут имеется ***Ansible Role,*** устанавливающая ***Docker*** и запускающая контейнер на вашей новой тачке.

Из каталога `/home/<user>/2048-game/` запусите плейбук:
```
ansible-playbook install_docker.yml
```
Теперь можно в адресно троке браузера указать ip-адрес вашей виртуальной машины и играть.

А на сегодня все, до новых встреч
![все](https://img2.joyreactor.cc/pics/post/длиннопост-реактор-помогающий-original-content-живность-5033160.gif)



ansible-galaxy install -r requirements.yml

chmod g+x ~/2048-game/run_terraform_output.sh

chmod g+r ~/.ssh/id_ed25519

chmod g+r ~/.ssh

