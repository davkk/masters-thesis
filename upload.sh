#!/usr/bin/env bash

for i in `seq 1 2`; do
    echo "Uploading for particle $i"
    o2-ccdb-upload \
        --host http://alice-ccdb.cern.ch \
        --path Users/d/dkarpins/Correction \
        --file EfficiencyCorrection.root \
        --key hWeights_part$i \
        --meta "dataset=LHC23d1k;particle=p"
done
