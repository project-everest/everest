#!/usr/bin/env bash

set -x

threads=$1
branchname=$2

build_home="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "$build_home"/everest-move-fun.sh

# Some environment variables we want
export OCAMLRUNPARAM=b
export MAKEFLAGS="$MAKEFLAGS -Otarget"
export V=1 # Verbose F* build

slack_file="slackmsg.txt"
build_feedback="build_feedback.json"

status_file="status.txt"
echo false >$status_file

if everest_move ; then
    echo true >$status_file
fi
