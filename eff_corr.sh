#!/bin/bash

set -euox pipefail

if [[ $# -ne 1 ]]; then
    echo 'Usage: ./eff_corr.sh <path>'
    exit 1
fi

if [[ -z "${O2PHYSICS_ROOT+x}" ]]; then
    echo 'wrong environment'
    exit 1
fi

IFS='/' read -r -a path <<< "$1"
pair=${path[-2]}

name=`basename ${0%.*}`
g++ `root-config --libs --glibs --cflags` --std=c++20 -O3 ${name}.cxx -o ${name}.out

./${name}.out \
    $1 \
    femto-universe-pair-task-track-track-extended_${pair}_nocor/Tracks_one \
    femto-universe-pair-task-track-track-extended_${pair}_nocor/MCTruthTracks_one
