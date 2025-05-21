#!/usr/bin/env bash

set -euo pipefail

file=$1

o2-ccdb-upload \
    --host http://ccdb-test.cern.ch:8080 \
    --path Users/d/dkarpins/Correction \
    --file $file \
    --key hWeights
