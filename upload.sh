#!/usr/bin/env bash

set -euo pipefail

o2-ccdb-upload \
    --host http://alice-ccdb.cern.ch \
    --path Users/d/dkarpins/Correction \
    --file ./data/LHC24f3c/p-p/EfficiencyCorrection1.root \
    --key hWeights \
    --meta "dataset=LHC24f3c;particle=p;trainRun=382926"
