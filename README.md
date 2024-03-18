# 2048-game
docker build -t 2048-game-image
docker run -d -p 80:8080 --name 2048-game 2048-game-image