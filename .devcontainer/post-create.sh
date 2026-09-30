#!/usr/bin/env bash

set -euo pipefail

sudo chown -R vscode:vscode /home/vscode/.aws /home/vscode/.ssh
chmod 700 /home/vscode/.ssh
terraform version
aws --version
docker --version
docker compose version
