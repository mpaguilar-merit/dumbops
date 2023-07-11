#!/bin/bash

# tmp token: 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

echo "This is a quick test"
echo "Target ruby version: $TARGET_RUBY_VER"
echo "Github SHA: $GITHUB_SHA"

export COMMIT_HASH=${GITHUB_SHA:0:8}
echo "Short commit hash: $COMMIT_HASH"

echo "Github ref name: $GITHUB_REF_NAME"

echo "Current directory: "
pwd

echo "Listing files:"
ls -al