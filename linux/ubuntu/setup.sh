#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update
sudo apt-get install -y $(grep -vE '^[[:space:]]*(#|$)' manifest.txt)
