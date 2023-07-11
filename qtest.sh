#!/bin/bash

# tmp token: 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

echo "This is a quick test"
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

cd build

echo "Listing build dir:"
ls -al

echo "Listing config dir:"
ls -al $CONFIG_DIR

# get utilities
echo "Retrieving yq"
wget -O $CONFIG_DIR/usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
chmod +x $CONFIG_DIR/usr/local/bin/yq
echo ""



