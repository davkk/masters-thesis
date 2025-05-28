#!/usr/bin/env bash

# if [[ -z "${O2PHYSICS_ROOT+x}" ]]; then
#     echo 'wrong environment'
#     exit 1
# fi

path=$1

# data/<dataset>/effcor/<particle>/<run>-1d.root
IFS='/' read -ra segments <<< "$path"
data_dir=${segments[0]}
effcor_dir=${segments[2]}

if [[ -z $data_dir ]] || [[ -z $effcor_dir ]] || [[ $data_dir != "data" ]] || [[ $effcor_dir != "effcor" ]]; then
    echo "Wrong path: $path"
    exit 1
fi

dataset=${segments[1]}
particle=${segments[3]}
run=${segments[4]%%-*}

if [[ -z $dataset ]] || [[ -z $particle ]] || [[ -z $run ]]; then
    echo "Wrong path: $path"
    exit 1
fi

o2-ccdb-upload \
    --host http://alice-ccdb.cern.ch \
    --path Users/d/dkarpins/Correction \
    --file $path \
    --key hWeights \
    --meta "dataset=${dataset};particle=${particle};trainRun=${run}"
