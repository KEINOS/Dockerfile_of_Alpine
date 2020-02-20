#!/bin/bash

cat <<'HEREDOC'
===============================================================================
  Local image builder for Tokyo locale ready Alpine image.
===============================================================================
This script builds Docker image for AMD64, ARM v6 and ARM v7 architecture. Then
pushes to Docker Hub the images made.

- Requirements:
    1. Experimental option must be enabled. (buildx command must be available to use)
    2. when "docker buildx ls" is run, below platforms must be listed:
        - linux/arm/v6, linux/arm/v7, linux/arm64

===============================================================================

HEREDOC

[ 'true' = $(docker version --format {{.Client.Experimental}}) ] || {
   echo 'Docker daemon not in experimental mode.'
   exit 1
}

# -----------------------------------------------------------------------------
#  Common Variables
# -----------------------------------------------------------------------------
NAME_IMAGE='keinos/alpine'
PATH_FILE_VER_INFO='VERSION.txt'
NAME_BUILDER=mybuilder

# -----------------------------------------------------------------------------
#  Main
# -----------------------------------------------------------------------------

# Load current Alpine version info
source ./$PATH_FILE_VER_INFO
VERSION_OS=$VERSION_ID
echo '- Current Alpine version:' $VERSION_OS

echo '- Login to Docker:'
docker login 2>/dev/null 1>/dev/null || {
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin || {
        echo 'You need to login Docker Cloud/Hub first.'
        exit 1
    }
}

echo '- docker buildx ls'
docker buildx ls

docker buildx ls | grep $NAME_BUILDER
[ $? -ne 0 ] && {
    echo '- Create builder: ' $NAME_BUILDER
    docker buildx create --name $NAME_BUILDER
}

echo '- Start build:'
docker buildx use $NAME_BUILDER
docker buildx inspect --bootstrap

# Build ARMv6
NAME_TAG='arm32v6'
docker buildx build \
    --build-arg \
        NAME_BASE="${NAME_TAG}/alpine" \
        VER_ALPINE="v${VERSION_OS}" \
    --platform linux/arm/v6 \
    -t "${NAME_IMAGE}:${NAME_TAG}" \
    --push . && \
docker pull "${NAME_IMAGE}:${NAME_TAG}"

# Build ARMv7
NAME_TAG='arm32v7'
docker buildx build \
    --build-arg \
        NAME_BASE="${NAME_TAG}/alpine" \
        VER_ALPINE="v${VERSION_OS}" \
    --platform linux/arm/v7 \
    -t "${NAME_IMAGE}:${NAME_TAG}" \
    --push . \
&& docker pull "${NAME_IMAGE}:${NAME_TAG}"

# Build AMD64
NAME_TAG='amd64'
docker buildx build \
    --build-arg \
        NAME_BASE="alpine" \
        VER_ALPINE="v${VERSION_OS}" \
    --platform linux/amd64 \
    -t "${NAME_IMAGE}:${NAME_TAG}" \
    --push . \
&& docker pull "${NAME_IMAGE}:${NAME_TAG}"

# Build ARM64
NAME_TAG='arm64'
docker buildx build \
    --build-arg \
        NAME_BASE="alpine" \
        VER_ALPINE="v${VERSION_OS}" \
    --platform linux/arm64 \
    -t "${NAME_IMAGE}:${NAME_TAG}" \
    --push . \
&& docker pull "${NAME_IMAGE}:${NAME_TAG}"

docker buildx imagetools inspect $NAME_IMAGE
docker buildx use default

# Create manifest list with latest tag
NAME_TAG_LATEST="${NAME_IMAGE}:latest"
docker image rm --force $NAME_TAG_LATEST 2>/dev/null 1>/dev/null
docker manifest create $NAME_TAG_LATEST \
    $NAME_IMAGE:amd64 \
    $NAME_IMAGE:arm32v6 \
    $NAME_IMAGE:arm32v7 \
    $NAME_IMAGE:arm64 \
    --amend
docker manifest annotate $NAME_TAG_LATEST \
    $NAME_IMAGE:arm32v6 --os linux --arch arm --variant v6l
docker manifest annotate $NAME_TAG_LATEST \
    $NAME_IMAGE:arm32v7 --os linux --arch arm --variant v7l
docker manifest inspect $NAME_TAG_LATEST
docker manifest push $NAME_TAG_LATEST --purge

# Create manifest list with current version
NAME_TAG_CURRENT="${NAME_IMAGE}:${VERSION_OS}"
docker image rm --force $NAME_TAG_CURRENT 2>/dev/null 1>/dev/null
docker manifest create $NAME_TAG_CURRENT \
    $NAME_IMAGE:amd64 \
    $NAME_IMAGE:arm32v6 \
    $NAME_IMAGE:arm32v7 \
    $NAME_IMAGE:arm64 \
    --amend
docker manifest annotate $NAME_TAG_CURRENT \
    $NAME_IMAGE:arm32v6 --os linux --arch arm --variant v6l
docker manifest annotate $NAME_TAG_CURRENT \
    $NAME_IMAGE:arm32v7 --os linux --arch arm --variant v7l
docker manifest inspect $NAME_TAG_CURRENT
docker manifest push $NAME_TAG_CURRENT --purge
