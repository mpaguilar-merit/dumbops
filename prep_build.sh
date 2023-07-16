#!/bin/bash

# exit on failure
set -e

echo "This is a test"
echo "Target ruby version: $TARGET_RUBY_VER"
echo "Github SHA: $GITHUB_SHA"

export COMMIT_HASH=${GITHUB_SHA:0:8}
echo "Short commit hash: $COMMIT_HASH"

echo "Github ref name: $GITHUB_REF_NAME"

CONFIG_DIR=./configs/basic

echo "Current directory: "
pwd

echo "Listing files:"
ls -al

mv app build

echo "Changing to build directory"
cd build

echo "Listing build dir:"
ls -al

echo "Listing config dir:"
ls -al $CONFIG_DIR

cp -r $CONFIG_DIR ./app

echo "Listing app dir"
ls -al ./app

# get utilities
echo "Retrieving yq"
# just in case it doesn't exist
mkdir -p $CONFIG_DIR/usr/local/bin
wget --no-verbose -O $CONFIG_DIR/usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
chmod +x $CONFIG_DIR/usr/local/bin/yq
echo "Done"
echo ""

IMG_TAG="mag-${TARGET_RUBY_VER}-${COMMIT_HASH}"

# set the image tag in the global environment so the docker step can find it
echo "IMG_TAG=$IMG_TAG" >> "$GITHUB_ENV"

# set the repository name
echo "ECR_REPOSITORY=merit" >> "$GITHUB_ENV"