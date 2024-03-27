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

Надеюсь у вас есть [Personal Access Token](https://gitlab.com/-/user_settings/personal_access_tokens)? Он нам пригодится в будущем.

Синхронизируйте ваш рабочий каталог `/home/<user>/2048-game` с репозиторием [GitLab:](https://about.gitlab.com/)
```
git remote remove github
git remote add gitlab https://gitlab.com/<user>/2048-game.git
git switch --create main
```

# Инициализируем Terraform и запустим виртуальную машину

Для начала следует создать каталог, сервисный аккаунт и назначить роли в соответствии с [документацией YC,](https://cloud.yandex.ru/ru/docs/tutorials/infrastructure-management/terraform-quickstart#before-you-begin)а так же создать авторизованный ключ для сервисного аккаунта.

*В нашем случае авторизованный ключ хранится в домашнем каталоге пользователя* `/home/<user>/`.

Установите пакет *terraform*
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

Создайте пару ключей SSH
```
ssh-keygen -t ed25519
```

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
terraform init && terraform apply && sh run_terraform_output.sh
```
скрипт run_terraform_output.sh обновит файл `hosts`, актуализировав ip-адрес виртуальной машины.

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

Приготовим все для подключения gitlab-runner по ssh:
``` 
sudo cp ~/.ssh/id_ed25519 /home/gitlab-runner/.ssh/id_ed25519
sudo chown gitlab-runner:gitlab-runner /home/gitlab-runner/.ssh/id_ed25519
sudo chmod +rw /home/gitlab-runner/.ssh/known_hos
```

В файле `/home/gitlab-runner/.bash_logout` закомментируйте директиву:
```
#if [ "$SHLVL" = 1 ]; then
#    [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
#fi
```
## Давайте устроим CI/CD

Здесь как раз нам и пригодится тот самый [Personal Access Token](https://gitlab.com/-/user_settings/personal_access_tokens) в качестве пароля к учетке, когда это потребуется.

Чтобs в ходе пайплайна докер мог подключаться к ***Container Registry*** создайте переменную в настройках [GitLab](https://about.gitlab.com/) `https://gitlab.com/<user>/2048-game/-/settings/ci_cd` в разделе `Variables` c:
Key: ACCESS_TOKEN
Value: [Personal Access Token](https://gitlab.com/-/user_settings/personal_access_tokens)

Зарегистрируйте gitlab-genner:
```
sudo gitlab-runner register
```
- в качестве URL укажате `https://gitlab.com/`
  
- регистрационный токен для ранера можно найти здесь `https://gitlab.com/<user>/2048-game/-/settings/ci_cd`

- добавьте тэги `buils,deploy,latest`.

Убедитесь, что вы находитесь в рабочем каталоге `/home/<user>/2048-game/`.

Введите команду:
```
git add .
```

Файл пайплайна `/home/<user>/2048-game/.gitlab-ci.yml` содержит команду, кторая вычлиняет цифры и точки из `commit message` и тэжит результатом образ.

Поэтому commit mesage должен быть примерно такой:
```
git commit -m "sdelal priemlemo, image version 1.0"
```

Пушим:
```
git push gitlab main
```
здесь в качестве пароль указываем [Personal Access Token.](https://gitlab.com/-/user_settings/personal_access_tokens)

В нашем пайплайне две стадии: ***build*** и ***deploy***.

В ***build*** соберется docker образ и отправится в ***Container Registry*** в двух версиях:
1. 1.0 `сочетание цифр и точек, которые мы указали в commit message`
2. latest

В ***deploy*** запустится ansible-playbook, который с помощью ansible-galaxy применит роль, запускающую на виртуальной машине контейнер из `latest` образа в нашем ***Container Registry.***

Теперь можно в адресной строке браузера указать ip-адрес вашей виртуальной машины и поиграть.

А на сегодня все, до новых встреч
![все](https://img2.joyreactor.cc/pics/post/длиннопост-реактор-помогающий-original-content-живность-5033160.gif)
