# 2048-game
export REGISTRY_ID=<идентификатор_реестра

docker build . -t cr.yandex/${REGISTRY_ID}/2048-game

docker image prune -f

docker push cr.yandex/${REGISTRY_ID}/2048-game

docker run -d -p 80:8080 --name 2048-game 2048-game-image