#!/usr/bin/env bash

for i in `seq 1 2`; do
    echo "Uploading for particle $i"
    o2-ccdb-upload \
        --path Users/d/dkarpins/Correction \
        --file EfficiencyCorrection.root \
        --key hWeights_part$i \
        --meta test=1
done
