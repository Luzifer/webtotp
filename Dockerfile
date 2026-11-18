FROM golang:1.27-alpine AS gobuild

ENV GOBIN=/rootfs/usr/bin

RUN <<-EOF
  set -ex
  apk --no-cache add \
    git

  install -dm0755 ${GOBIN}
  go install github.com/Luzifer/gziphttp@latest
EOF


FROM node:26.13.1-alpine AS nodebuild

COPY --from=ghcr.io/luzifer-docker/pnpm:v11.28.12 / /

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
