#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true
cd "$(dirname "$0")/.."
code .
