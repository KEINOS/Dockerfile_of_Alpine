#!/usr/bin/env bash

# This script checks the latest Alpine docker image version.
#
# Exits with a "1"(false) staus if no update found. If found, it will update
# the keinos/alpine:latest and version tags and exits with a status "0"(true).
#
# NOTE: This script must run on local and only was tested with macOS(Mojave).
#
# Update steps:
#   1. Pull alpine:latest image.
#   2. Gets the os-release version of the image above.
#   3. Compares the version between alpine:latest and keinos/alpine:latest.
#   4. Re-writes the version info of the Dockerfile.
#   5. Git add, commit and push if updated.

# Define Basic Variables
PATH_FILE_VER_INFO='VERSION.txt'

# Load current version info
. ./$PATH_FILE_VER_INFO
echo '- Current version:' $VERSION_ID

# Pull latest Alpine image
docker pull alpine:latest > /dev/null

# Fetch the latest Alpine version
VERSION_NEW=$(docker run --rm -i alpine:latest cat /etc/os-release | grep VERSION_ID | sed -e 's/[^0-9\.]//g')
echo '- Latest version:' $VERSION_NEW

# Compare
if [ $VERSION_ID = $VERSION_NEW ]; then
   echo 'No update found. Do nothing.'
   exit 1
fi

#  Update
# --------
echo 'Newer version found. Updating ...'

# Updating VERSION.txt
echo "VERSION_ID=${VERSION_NEW}" > ./$PATH_FILE_VER_INFO
if [ $? -ne 0 ]; then
  echo "* Failed update: ${PATH_FILE_VER_INFO}"
  exit 1
fi
echo "- Updated: ${PATH_FILE_VER_INFO}"

# Updating Alpine version label in Dockerfile
sed -i.previous -E "s/[0-9]+\.[0-9]+\.[0-9]/${VERSION_NEW}/" ./Dockerfile
if [ $? -ne 0 ]; then
  echo '* Failed update: Dockerfile'
  exit 1
fi
echo "- Updated: Dockerfile"

# Updating git
echo 'Commit and pushing to GitHub ...'
git add . && \
git commit -m "feat: Alpine v${VERSION_NEW}" && \
git tag "v${VERSION_NEW}" && \
git push --tags && \
git push origin
if [ $? -ne 0 ]; then
  echo '* Failed commit and push'
  exit 1
fi
echo "- Pushed: GitHub"

echo "Now wait until the Docker Hub's automated build finishes build the image."
