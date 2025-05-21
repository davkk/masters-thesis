#!/usr/bin/env bash

set -euox pipefail

if [[ -z "${O2PHYSICS_ROOT+x}" ]]; then
    echo 'wrong environment'
    exit 1
fi

name=`basename ${0%.*}`
g++ `root-config --libs --glibs --cflags` --std=c++20 -O3 ${name}.cxx -o ${name}.out
