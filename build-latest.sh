#!/bin/bash

set -eu

cat <<'HEREDOC'
===============================================================================
  Local image builder
===============================================================================
This script builds Docker image and pushes to Docker Hub. Run this script on
Mac and then on Raspberry Pi.

- On Mac:
    This script will update this repository, builds Docker image for AMD64 and
    pushes to Docker Hub. The image tag will be:
       keinos/alpine:arm64

- On Raspberry Pi:
    This script will update this repository, builds Docker image for ARM and
    pushes to Docker Hub. The image tag will be:
       keinos/alpine:arm

    Then pulls images of other architecture and creates a new manifest file for
    'keinos/alpine:latest' tag and pushes the manifest file.

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

LIST_TAG_PULL=("linux-arm" "linux-armv7l" "linux-armv6l" "darwin-amd64" "linux-amd64")

# -----------------------------------------------------------------------------
#  Functions
# -----------------------------------------------------------------------------
isMac () {
    sw_vers 2>/dev/null 1>/dev/null
    return $?
}

isPi () {
    #cat /proc/cpuinfo | grep "^model name\s*:\s*ARMv" 2>&1 > /dev/null
    grep --quiet "^model name\s*:\s*ARMv" /proc/cpuinfo 2>/dev/null 1>/dev/null
    return $?
}


# -----------------------------------------------------------------------------
#  Main
# -----------------------------------------------------------------------------

# Common

echo '- Docker login'
docker login

echo '- Updating git to origin'
git pull origin

echo '- Pulling Base Image'
docker pull alpine:latest

# Load current Alpine version info
. ./$PATH_FILE_VER_INFO
VERSION_OS=$VERSION_ID
echo '- Current Alpine version:' $VERSION_OS

echo "- Building image: ${NAME_TAG_IMAGE}"
docker build --no-cache -t $NAME_TAG_IMAGE .

echo '- Testing continer run'
docker run --rm $NAME_TAG_IMAGE cat /etc/os-release

if isMac ; then
   echo 'Image pushed done.'
   echo 'Now run this script on Raspberry Pi to push multi arch manifest'
   exit 0
fi

echo "- Pushing image: ${NAME_TAG_IMAGE}"
docker push $NAME_TAG_IMAGE

echo "- Removing image: ${NAME_TAG_IMAGE}"
docker image rm --force $NAME_TAG_IMAGE

echo "- Removing image: ${NAME_TAG_LATEST}"
docker image rm --force $NAME_TAG_LATEST

# Pull all images to inclue in manifest file
MANIFESTS=''
for NAME_TAG in ${LIST_TAG_PULL[@]}; do
    NAME_TAG_PULL="keinos/alpine:$NAME_TAG"
    echo "- Pulling: ${NAME_TAG_PULL}"
    docker pull $NAME_TAG_PULL && \
    MANIFESTS+=" ${NAME_TAG_PULL}"
done

# Create manifest list for latest tag and push
MANIFEST_LIST='keinos/alpine:latest'
echo '- Manifest list and manifests to include:' $MANIFEST_LIST$MANIFESTS
docker manifest create $MANIFEST_LIST$MANIFESTS --amend
docker manifest push $MANIFEST_LIST --purge

# Create manifest list for current vertion tag and push
MANIFEST_LIST="keinos/alpine:v$VERSION_OS"
echo '- Manifest list and manifests to include:' $MANIFEST_LIST$MANIFESTS
docker manifest create $MANIFEST_LIST$MANIFESTS --amend
docker manifest push $MANIFEST_LIST --purge
