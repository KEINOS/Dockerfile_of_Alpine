FROM alpine:latest AS build-env

RUN apk --update add tzdata && \
    echo 'Asia/Tokyo' > /etc/timezone

FROM alpine:latest
LABEL version_os="3.9.3"
COPY --from=build-env /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
COPY --from=build-env /etc/timezone /etc/timezone
