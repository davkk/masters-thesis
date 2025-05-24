#!/usr/bin/env bash

if [[ -z "${O2PHYSICS_ROOT+x}" ]]; then
    echo 'wrong environment'
    exit 1
fi

file=$1
train_run=$2
particle=$3

if [[ -z $file ]] || [[ -z $train_run ]]; then
    echo "Usage: $0 <file> <train_run>"
    exit 1
fi

o2-ccdb-upload \
    --host http://alice-ccdb.cern.ch \
    --path Users/d/dkarpins/Correction \
    --file $file \
    --key hWeights \
    --meta "dataset=LHC24f3c;particle=${particle};trainRun=${train_run}"
