FROM mhart/alpine-node:8

WORKDIR /opt/rope

ADD . .

RUN apk --no-cache add git bash openssh

RUN npm install -g gulp coffeescript@1

RUN npm run build
