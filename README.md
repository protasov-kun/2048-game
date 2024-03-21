# 2048-game

docker build . -t 2048-game-image

docker image prune -f

docker push 2048-game

docker run -d -p 80:8080 --name 2048-game 2048-game-image

curl -LJO "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/deb/gitlab-runner_amd64.deb"

sudo dpkg -i gitlab-runner_amd64.deb

Закоментить в /home/gitlab-runner/.bash_logout директиву:
if [ "$SHLVL" = 1 ]; then
    [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
fi

sudo apt update && sudo apt install ansible

ansible-playbook install_docker.yml -i inventory.yaml  --ask-become-pass