FROM golang:alpine as go

RUN set -ex \
 && apk add git \
 && go install github.com/Luzifer/gziphttp@latest


FROM node:16-alpine as node

COPY . /src
WORKDIR /src

RUN set -ex \
 && npm ci \
 && npm run build


FROM alpine:latest

COPY --from=go    /go/bin/gziphttp  /usr/local/bin/
COPY --from=node  /src/dist         /usr/local/share/webtotp

EXPOSE 3000/tcp
CMD ["gziphttp", "-d", "/usr/local/share/webtotp"]
