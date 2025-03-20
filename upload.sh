#!/usr/bin/env bash

# for i in `seq 1 2`; do
#     echo "Uploading for particle $i"
#     o2-ccdb-upload \
#         --host http://alice-ccdb.cern.ch \
#         --path Users/d/dkarpins/Correction \
#         --file ./data/LHC23d1k/pi-api/EfficiencyCorrection.root \
#         --key hWeights_part$i \
#         --meta "dataset=LHC23d1k;particle=pi"
# done

o2-ccdb-upload \
    --host http://alice-ccdb.cern.ch \
    --path Users/d/dkarpins/Correction \
    --file ./data/LHC23d1k/pi-api/EfficiencyCorrection.root \
    --key hWeights_part1 \
    --meta "dataset=LHC23d1k;particle=pi;trainRun=373670"

o2-ccdb-upload \
    --host http://alice-ccdb.cern.ch \
    --path Users/d/dkarpins/Correction \
    --file ./data/LHC23d1k/pi-api/EfficiencyCorrection.root \
    --key hWeights_part2 \
    --meta "dataset=LHC23d1k;particle=api;trainRun=373670"
