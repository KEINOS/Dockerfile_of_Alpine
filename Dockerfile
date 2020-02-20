ARG NAME_BASE
ARG VER_ALPINE

FROM ${NAME_BASE} AS build-env

RUN apk --no-cache add tzdata && \
    echo 'Asia/Tokyo' > /etc/timezone

FROM ${NAME_BASE}
LABEL alpine=${VER_ALPINE}
COPY --from=build-env /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
COPY --from=build-env /etc/timezone /etc/timezone
