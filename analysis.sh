#!/usr/bin/env bash

args=`cat datafiles.csv | fzf --layout=reverse | tr "," " "`
if [[ -z $args ]]; then
    exit 0
fi

fd .py analysis/ | parallel --progress echo $args \| xargs python {}
