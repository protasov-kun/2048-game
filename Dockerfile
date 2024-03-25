FROM node:16 AS build
WORKDIR /usr/src/app
COPY /2048-game/package.json .
RUN npm install --include=dev
COPY /2048-game/ .
RUN npm run build

FROM alpine:latest AS final
WORKDIR /usr/src/app
COPY --from=build /usr/src/app .
RUN apk update \
    && apk add --no-cache nodejs npm \
    && rm -rf /var/cache/apk/*
EXPOSE 8080
CMD ["npm", "start"]
