#!/bin/bash

cat <<'HEREDOC'

NOTE: Run check-update.sh which calls this script.

===============================================================================
  Local image builder for Tokyo locale ready Alpine image.
===============================================================================
This script builds Docker image for AMD64, ARM v6 and ARM v7 architecture. Then
pushes to Docker Hub the images made.

- Requirements:
    1. Experimental option must be enabled. (buildx command must be available to use as well)
    2. When running "docker buildx ls", the below platforms must be listed:
        - linux/arm/v6
        - linux/arm/v7
        - linux/arm64
        - linux/amd64

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
#  Functions
# -----------------------------------------------------------------------------

function build_push_pull_image () {
    echo "- BUILDING ${NAME_PLATFORM}"
    docker buildx build \
        --build-arg NAME_BASE=$NAME_BASE \
        --build-arg VER_ALPINE="v${VERSION_OS}" \
        --platform $NAME_PLATFORM \
        -t "${NAME_IMAGE}:${NAME_TAG}" \
        --push . && \
    echo "  PULLING BACK: ${NAME_IMAGE}:${NAME_TAG}" && \
    docker pull "${NAME_IMAGE}:${NAME_TAG}"

    return $?
}

function create_builder () {
    echo '- Create builder: ' $1
    docker buildx ls | grep $1 1>/dev/null
    [ $? -ne 0 ] && {
        docker buildx create --name $1
    }

    return $?
}

function create_manifest () {
    echo '- Removing image from local:'
    docker image rm --force $1 2>/dev/null 1>/dev/null
    echo "- Creating manifest for: $1"
    echo "  With images: ${2}"
    docker manifest create $1 $2 --amend

    return $?
}

function login_docker () {
    echo -n '- Login to Docker: '
    docker login 2>/dev/null 1>/dev/null || {
        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin || {
            echo 'You need to login Docker Cloud/Hub first.'
            exit 1
        }
    }
    echo 'OK'
}

function rewrite_variant_manifest () {
    echo "- Re-writing variant to: $3"
    docker manifest annotate $1 $2 --variant $3

    return $?
}

# -----------------------------------------------------------------------------
#  Main
# -----------------------------------------------------------------------------

# Load current Alpine version info
source ./$PATH_FILE_VER_INFO
VERSION_OS=$VERSION_ID
echo '- Current Alpine version:' $VERSION_OS

login_docker

create_builder $NAME_BUILDER

echo '- Start build:'
docker buildx use $NAME_BUILDER
docker buildx inspect --bootstrap

# Build ARMv6
NAME_BASE='arm32v6/alpine'
NAME_TAG='armv6'
NAME_PLATFORM='linux/arm/v6'
build_push_pull_image

# Build ARMv7
NAME_BASE='arm32v7/alpine'
NAME_TAG='armv7'
NAME_PLATFORM='linux/arm/v7'
build_push_pull_image

# Build AMD64
NAME_BASE='alpine'
NAME_TAG='amd64'
NAME_PLATFORM='linux/amd64'
build_push_pull_image

# Build ARM64
NAME_BASE='alpine'
NAME_TAG='arm64'
NAME_PLATFORM='linux/arm64'
build_push_pull_image

echo "- Inspect built image of: ${NAME_IMAGE}"
docker buildx imagetools inspect $NAME_IMAGE

echo '- Switch back builder to default:'
docker buildx stop $NAME_BUILDER
docker buildx use default

# Create manifest
LIST_IMAGE_INCLUDE="$NAME_IMAGE:armv6 $NAME_IMAGE:armv7 $NAME_IMAGE:arm64 $NAME_IMAGE:amd64"

echo "- Creating manifest for image: ${NAME_IMAGE} with: latest tag"
NAME_IMAGE_AND_TAG="${NAME_IMAGE}:latest"
create_manifest  $NAME_IMAGE_AND_TAG "$LIST_IMAGE_INCLUDE"

rewrite_variant_manifest $NAME_IMAGE_AND_TAG $NAME_IMAGE:armv6 v6l
rewrite_variant_manifest $NAME_IMAGE_AND_TAG $NAME_IMAGE:armv7 v7l

docker manifest inspect $NAME_IMAGE_AND_TAG && \
docker manifest push $NAME_IMAGE_AND_TAG --purge

# Create manifest list with current version
echo "- Creating manifest for image: ${NAME_IMAGE} with: v${VERSION_OS} tag"
NAME_IMAGE_AND_TAG="${NAME_IMAGE}:v${VERSION_OS}"

create_manifest  $NAME_IMAGE_AND_TAG "$LIST_IMAGE_INCLUDE"

rewrite_variant_manifest $NAME_IMAGE_AND_TAG $NAME_IMAGE:armv6 v6l
rewrite_variant_manifest $NAME_IMAGE_AND_TAG $NAME_IMAGE:armv7 v7l

docker manifest inspect $NAME_IMAGE_AND_TAG && \
docker manifest push $NAME_IMAGE_AND_TAG --purge
