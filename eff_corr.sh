#!/bin/bash

set -euox pipefail

name=`basename ${0%.*}`

g++ `root-config --libs --glibs --cflags` --std=c++20 -O3 ${name}.cxx -o ${name}.out

# ./${name}.out \
#     ./data/LHC24f3c/p-p/377751.root \
#     femto-universe-pair-task-track-track-extended_p-p_nocor/Tracks_one \
#     femto-universe-pair-task-track-track-extended_p-p_nocor/MCTruthTracks_one
# mv ./data/LHC24f3c/p-p/EfficiencyCorrection.root ./data/LHC24f3c/p-p/EfficiencyCorrection1.root

./${name}.out \
    ./data/LHC23d1k/pi-api/373670.root \
    femto-universe-pair-task-track-track-extended_pi-api_nocor/Tracks_one \
    femto-universe-pair-task-track-track-extended_pi-api_nocor/MCTruthTracks_one
mv ./data/LHC23d1k/pi-api/EfficiencyCorrection.root ./data/LHC23d1k/pi-api/EfficiencyCorrection1.root

./${name}.out \
    ./data/LHC23d1k/pi-api/373670.root \
    femto-universe-pair-task-track-track-extended_pi-api_nocor/Tracks_two \
    femto-universe-pair-task-track-track-extended_pi-api_nocor/MCTruthTracks_two
mv ./data/LHC23d1k/pi-api/EfficiencyCorrection.root ./data/LHC23d1k/pi-api/EfficiencyCorrection2.root

# rootbrowse ./data/LHC23d1k/pi-api/EfficiencyCorrection.root
