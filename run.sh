#!/usr/bin/env bash

set -euo pipefail
IFS=',' read -r -a args <<< "$2"

python $1 "${args[@]:1}"
