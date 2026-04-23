#!/bin/bash

shopt -s expand_aliases

# import alias
if [ -n "$1" ]; then
    eval "$1"
fi

if [ -f ./build.sh ]; then
    ./build.sh
elif [ -f ../build.sh ]; then
    ../build.sh
elif [ -f ../../build.sh ]; then
    ../../build.sh
else
    :
fi
