#!/usr/bin/env bash

o2-ccdb-upload \
    --host http://alice-ccdb.cern.ch \
    --path Users/d/dkarpins/Correction \
    --file ./data/LHC23d1k/pi-api/EfficiencyCorrection.root \
    --key hWeights \
    --meta "dataset=LHC23d1k;particle=api;trainRun=373670"
