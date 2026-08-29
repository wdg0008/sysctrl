#!/usr/bin/env bash
set -euo pipefail

pacman -S --needed --noconfirm \
    $(grep -vE '^[[:space:]]*(#|$)' packages.txt | tr '\n' ' ')
