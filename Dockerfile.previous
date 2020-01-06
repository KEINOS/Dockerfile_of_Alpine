FROM alpine:latest AS build-env

RUN apk --update add tzdata && \
    echo 'Asia/Tokyo' > /etc/timezone

FROM alpine:latest
LABEL alpine="3.10.3"
COPY --from=build-env /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
COPY --from=build-env /etc/timezone /etc/timezone
