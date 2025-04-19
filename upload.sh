#!/usr/bin/env bash

set -euo pipefail

o2-ccdb-upload \
    --host http://alice-ccdb.cern.ch \
    --path Users/d/dkarpins/Correction \
    --file ./data/LHC24f3c/pi-api/387037-effcor-1744287852397.root \
    --key hWeights \
    --meta "dataset=LHC24f3c;particle=api;trainRun=387037"
