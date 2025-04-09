#!/usr/bin/env bash

set -euo pipefail
echo $2 | sed "s/^[01],//" | tr "," " " | xargs python $1
