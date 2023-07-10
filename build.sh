#!/bin/bash

docker build -t dink-webapp .
docker tag dink-webapp:latest 987758770978.dkr.ecr.us-west-2.amazonaws.com/dink-webapp:latest
docker push 987758770978.dkr.ecr.us-west-2.amazonaws.com/dink-webapp:latest