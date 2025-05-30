#!/usr/bin/env bash

if [[ -z $1 ]]; then
    echo 'usage: ./compile_root.sh <name>'
    exit 1
fi

set -euox pipefail

# if [[ -z "${O2PHYSICS_ROOT+x}" ]]; then
#     echo 'wrong environment'
#     exit 1
# fi

name=`basename ${1%.*}`
g++ `root-config --libs --glibs --cflags` --std=c++23 -O3 ${name}.cxx -o ${name}.out
