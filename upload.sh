#!/usr/bin/env bash

set -euo pipefail

train_run=388604

# o2-ccdb-upload \
#     --host http://alice-ccdb.cern.ch \
#     --path Users/d/dkarpins/Correction \
#     --file ./data/LHC24f3c\(nocont\)/pi-api/${train_run}-1-effcor.root \
#     --key hWeights \
#     --meta "dataset=LHC24f3c;particle=pi;trainRun=${train_run};nocont=1"

o2-ccdb-upload \
    --host http://alice-ccdb.cern.ch \
    --path Users/d/dkarpins/Correction \
    --file ./data/LHC24f3c/p-p/388604.root \
    --key hWeights \
    --meta "dataset=LHC24f3c;particle=p;trainRun=388604"
