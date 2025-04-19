#!/bin/bash

set -euox pipefail

if [[ $# -ne 2 ]]; then
    echo 'Usage: ./eff_corr.sh <is-same(0|1)> <path>'
    exit 1
fi

if [[ -z "${O2PHYSICS_ROOT+x}" ]]; then
    echo 'wrong environment'
    exit 1
fi

is_same=$1

IFS='/' read -r -a path <<< "$2"
pair=${path[-2]}

name=`basename ${0%.*}`
g++ `root-config --libs --glibs --cflags` --std=c++20 -O3 ${name}.cxx -o ${name}.out

./${name}.out \
    $2 \
    femto-universe-pair-task-track-track-extended_${pair}_nocor/Tracks_one \
    femto-universe-pair-task-track-track-extended_${pair}_nocor/MCTruthTracks_one

if [[ $is_same -eq 0 ]]; then
    ./${name}.out \
        $2 \
        femto-universe-pair-task-track-track-extended_${pair}_nocor/Tracks_two \
        femto-universe-pair-task-track-track-extended_${pair}_nocor/MCTruthTracks_two
fi
