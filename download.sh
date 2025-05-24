#!/usr/bin/env bash

if [[ -z "${O2PHYSICS_ROOT+x}" ]]; then
    echo 'wrong environment'
    exit 1
fi

alien_path=$1
data_path=$2

if [[ -z "${alien_path}" ]]; then
    echo "Usage: $0 <alien_path>"
    exit 1
fi

IFS='/' read -ra path <<< "${alien_path}"
run=${path[-3]}

mkdir -p ${data_path}
alien.py cp $alien_path file:${data_path}/${run}.root
