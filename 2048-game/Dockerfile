FROM node:16 AS build
WORKDIR /usr/src/app
COPY package.json .
RUN npm install --include=dev
COPY . .
RUN npm run build

FROM alpine:latest AS final
WORKDIR /usr/src/app
COPY --from=build /usr/src/app .
RUN apk update \
    && apk add --no-cache nodejs npm \
    && rm -rf /var/cache/apk/*
EXPOSE 8080
CMD ["npm", "start"]