#!/usr/bin/env bash

set -euo pipefail
echo $2 | tr "," " " | xargs python $1
