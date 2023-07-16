#!/bin/bash

# apt update
# apt upgrade -y

export PATH=$PATH:/root/.local/bin

# why was I installing poetry?
# curl -sSL https://install.python-poetry.org | python3 -
# poetry install --no-root

echo "Doing some stuff" >> stuff.txt
echo "Stuff dot text"
cat stuff.txt

echo "Current directory"
pwd

ls -al