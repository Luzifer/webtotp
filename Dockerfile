FROM golang:1.27.4-alpine@sha256:70bd7ddea8b6cbe5d6943cde279d6b67feb10cc924fb9100d1d8757c1575b280 AS gobuild

ENV GOBIN=/rootfs/usr/bin

RUN <<-EOF
  set -ex
  apk --no-cache add \
    git

  install -dm0755 ${GOBIN}
  go install github.com/Luzifer/gziphttp@v0.1.5
EOF


FROM node:26.13.1-alpine@sha256:6bd9ab43c0ec0190ca7b2d193906cb8b7edf6e7f4afa43ddeccd6452710bffb5 AS nodebuild

COPY --from=ghcr.io/luzifer-docker/pnpm:v11.28.13@sha256:4e66f7400935a022ec40caf62525c312a085abda96c8e93a78d39e61be9ece27 / /

COPY . /src
WORKDIR /src

RUN <<-EOF
  set -ex

  apk --no-cache add \
    make

  make prod

  install -Dm0644 -t /rootfs/usr/share/webtotp \
    dist/*
EOF

COPY --from=gobuild /rootfs/ /rootfs/


FROM scratch AS final

COPY --from=nodebuild /rootfs/ /

USER 13337
ENTRYPOINT ["/usr/bin/gziphttp"]
CMD ["-d", "/usr/share/webtotp"]
