#!/bin/bash

set -eu

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

# -----------------------------------------------------------------------------
#  Common Variables
# -----------------------------------------------------------------------------
NAME_CPU_ARCH=$(docker version --format '{{.Client.Arch}}')
NAME_OS=$(docker version --format '{{.Client.Os}}')
PATH_FILE_VER_INFO='VERSION.txt'
NAME_TAG_IMAGE="keinos/alpine:${NAME_OS}-${NAME_CPU_ARCH}"
NAME_TAG_LATEST='keinos/alpine:latest'
LIST_TAG_PULL=("arm32v6" "arm32v7" "arm64" "amd64")
NAME_INSTANCE_BUILDER=mybuilder

# -----------------------------------------------------------------------------
#  Functions
# -----------------------------------------------------------------------------
isExperimantal () {
    [ 'true' = $(docker version --format {{.Client.Experimental}}) ] && {
        return 0
    }
    return 1
}

isMac () {
    sw_vers 2>/dev/null 1>/dev/null
    return $?
}

isPi () {
    #cat /proc/cpuinfo | grep "^model name\s*:\s*ARMv" 2>&1 > /dev/null
    grep --quiet "^model name\s*:\s*ARMv" /proc/cpuinfo 2>/dev/null 1>/dev/null
    return $?
}

if ! isExperimantal ; then
   echo 'Docker daemon not in experimental mode.'
   exit 0
fi

# -----------------------------------------------------------------------------
#  Main
# -----------------------------------------------------------------------------

echo '- Docker login'
docker login

echo '- Building images and pushing to server ... '
docker buildx ls | grep $NAME_INSTANCE_BUILDER && {
    docker buildx rm
}

docker buildx ls | grep amd64 | grep arm64 | grep arm/v7 | grep arm/v6 && \
docker buildx create --name $NAME_INSTANCE_BUILDER && \
docker buildx use $NAME_INSTANCE_BUILDER && \
docker buildx inspect --bootstrap

docker buildx build \
    --pull \
    --platform linux/arm/v6 \
    --file ./Dockerfile.arm32v6 \
    -t keinos/alpine:arm32v6 \
    --push .

docker buildx build \
    --pull \
    --platform linux/arm/v7 \
    --file ./Dockerfile.arm32v7 \
    -t keinos/alpine:arm32v7 \
    --push .

docker buildx build \
    --pull \
    --platform linux/arm64 \
    -t keinos/alpine:arm64 \
    --push .

docker buildx build \
    --pull \
    --platform linux/amd64 \
    -t keinos/alpine:amd64 \
    --push .

#echo '- Updating git to origin'
#git pull origin

# Load current Alpine version info
. ./$PATH_FILE_VER_INFO
VERSION_OS=$VERSION_ID
echo '- Current Alpine version:' $VERSION_OS

echo "- Removing latest image: ${NAME_TAG_LATEST}"
docker image rm --force $NAME_TAG_LATEST

# Pull all images to inclue in manifest file
MANIFESTS=''
for NAME_TAG in ${LIST_TAG_PULL[@]}; do
    NAME_TAG_PULL="keinos/alpine:$NAME_TAG"
    #echo "- Removing image from local: ${NAME_TAG_PULL}"
    #docker image rm --force $NAME_TAG_PULL
    #echo "- Pulling: ${NAME_TAG_PULL}"
    #docker pull $NAME_TAG_PULL && \
    MANIFESTS+=" ${NAME_TAG_PULL}"
done

# Create manifest list for latest tag and push
MANIFEST_LIST=$NAME_TAG_LATEST
echo '- Manifest list and manifests to include:' $MANIFEST_LIST$MANIFESTS
docker manifest create $MANIFEST_LIST$MANIFESTS --amend
docker manifest push $MANIFEST_LIST --purge

# Create manifest list for current vertion tag and push
MANIFEST_LIST="keinos/alpine:v$VERSION_OS"
echo '- Manifest list and manifests to include:' $MANIFEST_LIST$MANIFESTS
docker manifest create $MANIFEST_LIST$MANIFESTS --amend
docker manifest push $MANIFEST_LIST --purge
