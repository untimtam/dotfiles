#!/usr/bin/env bash

set -euo pipefail

if command -v rustup >/dev/null 2>&1; then
    echo "rustup already installed"
else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi
