#!/usr/bin/env bash

#set -x

target=$1
out_file=$2
threads=$3

function export_home() {
    if command -v cygpath >/dev/null 2>&1; then
        export $1_HOME=$(cygpath -m "$2")
    else
        export $1_HOME="$2"
    fi
}

function everest_rebuild() {
    if [[ -x /usr/bin/time ]]; then
        gnutime=/usr/bin/time
    else
        gnutime=""
    fi

    git clean -ffdx
    $gnutime ./everest --yes -j $threads check reset make &&
        echo "done with check reset make, timing above" &&
        $gnutime ./everest --yes -j $threads test &&
        echo "done with test, timing above" &&
        $gnutime ./everest --yes -j $threads verify &&
        echo "done with verify, timing above"
}

function exec_build() {
    result_file="result.txt"

    # $status_file is the name of a file that contains true if and
    # only if the F* regression suite failed, false otherwise
    status_file="status.txt"
    echo false >$status_file

    ORANGE_FILE="orange_file.txt"
    echo '' >$ORANGE_FILE

    # Clone all projects together and make sure they test and build together
    if ! [ -x everest ]; then
        echo "Not in the right directory"
        return
    fi

    if [[ $target == "everest-ci" ]]; then
        everest_rebuild && echo true >$status_file
    elif [[ $localTarget == "everest-ci-windows" ]]; then
        exit 1
    elif [[ $localTarget == "everest-nightly-check" ]]; then
        exit 1
    elif [[ $localTarget == "everest-nightly-move" ]]; then
    else
        echo "Invalid target"
        return
    fi

    if [[ $(cat $status_file) != "true" ]]; then
        echo "Everest failed"
        echo Failure >$result_file
    else
        echo "Everest succeeded"
        echo Success >$result_file
    fi
}

# Some environment variables we want
export OCAMLRUNPARAM=b
export OTHERFLAGS="--print_z3_statistics --use_hints --query_stats"
export MAKEFLAGS="$MAKEFLAGS -Otarget"

exec_build
