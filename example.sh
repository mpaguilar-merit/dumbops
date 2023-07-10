#!/bin/bash

# exit on failure
set -e

# Destination directory for everything
BUILD_DIR=/home/michael/projects/merit_legacy/build
TARGET_RUBY_VER=${TARGET_RUBY_VER:-238}
GIT_BRANCH_NAME=${GIT_BRANCH_NAME:-develop}

echo "Targeting Ruby $TARGET_RUBY_VER"

# for now, CONFIG_DIR refers to a local drive
# Anything using the env var will have to moved to a remote resource
# accessible to the build agent
CONFIG_DIR=${CONFIG_DIR:-/home/michael/projects/merit_legacy/configs/ruby$TARGET_RUBY_VER}

echo "Container config directory: $CONFIG_DIR"

cd $BUILD_DIR

# remove any leftover artifacts
# NOTE: this script is in $BUILD_DIR
echo "Removing working directories"
rm -Rf $BUILD_DIR/app
rm -Rf $BUILD_DIR/config

# for any files that go with the app
mkdir -p $BUILD_DIR/app

# config files that go elsewhere on the filesystem
mkdir -p $BUILD_DIR/config

# git-specific items
pushd app

# get the app code
git clone git@github.com:meritpages/merit.git .
git checkout $GIT_BRANCH_NAME

# get the commit hash
COMMIT_HASH=`git rev-parse --short HEAD`

echo ""

# return to whichever directory this was started
popd

# get the dockerfile

echo "Using Dockerfile: $CONFIG_DIR/Dockerfile.ruby$TARGET_RUBY_VER"
cp $CONFIG_DIR/Dockerfile.ruby$TARGET_RUBY_VER $BUILD_DIR/Dockerfile

echo ""

# get utilities
echo "Retrieving yq"
wget -O $CONFIG_DIR/usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
chmod +x $CONFIG_DIR/usr/local/bin/yq
echo ""


echo "Copying $CONFIG_DIR to $BUILD_DIR/config/"
cp -r $CONFIG_DIR/ $BUILD_DIR/config/
echo ""

IMG_TAG="$TARGET_RUBY_VER:$COMMIT_HASH"

echo "========================================"
echo "Building image ruby$IMG_TAG in build directory $BUILD_DIR"
echo "========================================"
echo ""

#
# Build the image
#

# Change this to use Dockerfile in ./app
pushd $BUILD_DIR
#
docker build --progress=plain -t ruby$IMG_TAG .
last_exit=$?
if [ $last_exit -ne 0 ]
then
    echo "Error executing last command"
    exit $last_exit
fi

echo Build complete for 777116003911.dkr.ecr.us-east-1.amazonaws.com/merit:ruby$TARGET_RUBY_VER-$COMMIT_HASH
echo "========================================"
popd

echo "Tagging and pushing image ruby$IMG_TAG as merit:ruby$TARGET_RUBY_VER-$COMMIT_HASH"

# Tag images
docker tag ruby$IMG_TAG 777116003911.dkr.ecr.us-east-1.amazonaws.com/merit:ruby$TARGET_RUBY_VER
docker tag ruby$IMG_TAG 777116003911.dkr.ecr.us-east-1.amazonaws.com/merit:ruby$TARGET_RUBY_VER-$COMMIT_HASH

#
# Push image
#
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 777116003911.dkr.ecr.us-east-1.amazonaws.com
docker push 777116003911.dkr.ecr.us-east-1.amazonaws.com/merit:ruby$TARGET_RUBY_VER
docker push 777116003911.dkr.ecr.us-east-1.amazonaws.com/merit:ruby$TARGET_RUBY_VER-$COMMIT_HASH


echo Push complete for 777116003911.dkr.ecr.us-east-1.amazonaws.com/merit:ruby$TARGET_RUBY_VER-$COMMIT_HASH

exit

#
# Oh, boy, look at this jq....
#
export TASK_DEFINITION_IMAGE=777116003911.dkr.ecr.us-east-1.amazonaws.com/merit:ruby$TARGET_RUBY_VER-$COMMIT_HASH


aws ecs describe-task-definition --no-cli-pager --task-definition merit-app-staging-webapp | \
jq -r --arg image_name "$TASK_DEFINITION_IMAGE" '(.taskDefinition.containerDefinitions[] | select(.name == "merit-webapp") | .image ) |= $image_name | .taskDefinition | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities) | del(.registeredAt) | del(.registeredBy)' \
> new_task.json

aws ecs register-task-definition --cli-input-json file://new_task.json --no-cli-pager

#
# Update task definition
#
# echo "Updating task definition (force redeploy)"
# aws ecs update-service --no-cli-pager --cluster merit-app-web-staging-cluster --service web-app-service --force-new-deployment

aws ecs update-service --no-cli-pager \
--cluster merit-app-web-staging-cluster \
--service web-app-service \
--task-definition merit-app-staging-webapp | \
jq -r 'del(.service.events)'

echo Waiting on service...
aws ecs wait services-stable --cluster merit-app-web-staging-cluster --service web-app-service

