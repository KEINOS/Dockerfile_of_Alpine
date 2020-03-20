ARG NAME_BASE
ARG VER_ALPINE

FROM ${NAME_BASE} AS build-env

RUN apk --no-cache add tzdata && \
    echo 'Asia/Tokyo' > /etc/timezone

FROM ${NAME_BASE}
LABEL alpine=${VER_ALPINE}
RUN \
    # Fix the missing dependency to avoid "not found" error even the Golang compiled binary exists in Alpine.
    # - REF: https://stackoverflow.com/questions/34729748/installed-go-binary-not-found-in-path-on-alpine-linux-docker
    ! [ -f /lib64/ld-linux-x86-64.so.2 ] && \
    { mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2; }

COPY --from=build-env /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
COPY --from=build-env /etc/timezone /etc/timezone
