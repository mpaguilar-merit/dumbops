#!/bin/bash

# apt update
# apt upgrade -y

curl -sSL https://install.python-poetry.org | python3 -
export PATH=$PATH:/root/.local/bin

poetry install --no-root

