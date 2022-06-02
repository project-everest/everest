#!/usr/bin/env bash

#set -x

target=$1
out_file=$2
threads=$3
branchname=$4

function export_home() {
    local home_path=""
    if command -v cygpath >/dev/null 2>&1; then
        home_path=$(cygpath -m "$2")
    else
        home_path="$2"
    fi

    export $1_HOME=$home_path

    # Update .bashrc file
    local s_token=$1_HOME=
    if grep -q "$s_token" ~/.bashrc; then
        sed -i -E "s@$s_token.*@$s_token$home_path@" ~/.bashrc
    else
        echo "export $1_HOME=$home_path" >> ~/.bashrc
    fi
}

function everest_rebuild() {
    if [[ -x /usr/bin/time ]]; then
        gnutime=/usr/bin/time
    else
        gnutime=""
    fi

    git clean -ffdx
    $gnutime ./everest --yes -j $threads $1 check reset make &&
        echo "done with check reset make, timing above" &&
	source $HOME/.bashrc && # necessary if `everest check` just upgraded z3
        $gnutime ./everest --yes -j $threads $1 test &&
        echo "done with test, timing above" &&
        $gnutime ./everest --yes -j $threads $1 verify &&
        echo "done with verify, timing above"
}

build_home="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "$build_home"/everest-move-fun.sh

function exec_build() {
    cd everest

    result_file="../result.txt"

    # $status_file is the name of a file that contains true if and
    # only if the F* regression suite failed, false otherwise
    status_file="../status.txt"
    echo false >$status_file

    # Clone all projects together and make sure they test and build together
    if ! [ -x everest ]; then
        echo "Not in the right directory"
    else
        if [[ $target == "everest-ci" ]]; then
            if [[ "$OS" == "Windows_NT" ]]; then
                everest_rebuild -windows &&
                # collect sources and build with MSVC
                ./everest drop qbuild &&
                echo true >$status_file
            else
                everest_rebuild && echo true >$status_file
            fi
        elif [[ $target == "everest-move" ]]; then
            slack_file="../slackmsg.txt"
            build_feedback="../build_feedback.json"
            everest_move && echo true >$status_file
        else
            echo "Invalid target"
        fi
    fi

    if [[ $(cat $status_file) != "true" ]]; then
        echo "Everest failed"
        echo Failure >$result_file
    else
        echo "Everest succeeded"
        echo Success >$result_file
    fi

    cd ..
}

# Some environment variables we want
export OCAMLRUNPARAM=b
export OTHERFLAGS="--use_hints --query_stats"
export MAKEFLAGS="$MAKEFLAGS -Otarget"
export V=1 # Verbose F* build

exec_build
