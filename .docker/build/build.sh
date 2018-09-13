#!/usr/bin/env bash

#set -x

target=$1
out_file=$2
threads=$3
branchname=$4

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
    $gnutime ./everest --yes -j $threads $1 check reset make &&
        echo "done with check reset make, timing above" &&
        $gnutime ./everest --yes -j $threads $1 test &&
        echo "done with test, timing above" &&
        $gnutime ./everest --yes -j $threads $1 verify &&
        echo "done with verify, timing above"
}

function everest_move() {

    slack_file="../slackmsg.txt"

    # Figure out the branch
    CI_BRANCH=${branchname##refs/heads/}
    echo "Current branch_name=$CI_BRANCH"

    # This function is called from a test... so it needs to fast-fail because "set
    # -e" does not apply within subshells.

    # VSTS does not clean things properly... no point in fighting that, let's just
    # do it ourselves
    git clean -ffdx
    # Sanity check that will fail if something is off the rails
    ./everest --yes -j $threads check reset || return 1
    # Update every project to its know good version and branch, then for each
    # project run git pull
    source hashes.sh
    source repositories.sh
    local fresh=false
    local versions=""
    local url=""
    for r in ${!hashes[@]}; do
        cd $r
        git pull
        if [[ $(git rev-parse HEAD) != ${hashes[$r]} ]]; then
            fresh=true
            url=${repositories[$r]#git@github.com:}
            url="https://www.github.com/${url%.git}/compare/${hashes[$r]}...$(git rev-parse HEAD)"
            versions="$versions\n    *$r* <$url|moves to $(git rev-parse HEAD | cut -c 1-8)> on branch ${branches[$r]}"
        else
            versions="$versions\n    *$r* stays at $(git rev-parse HEAD | cut -c 1-8) on branch ${branches[$r]}"
        fi
        cd ..
    done
    versions="$versions\n"
    local msg=""
    if ! $fresh; then
        # Bail out early if there's nothing to do
        MsgToSlack=":information_source: *Nightly Everest Upgrade ($CI_BRANCH):* nothing to upgrade"
        echo $MsgToSlack >$slack_file
    elif ! ./everest --yes -j $threads -windows make test verify drop qbuild; then
        # Provide a meaningful summary of what we tried
        msg=":no_entry: *Nightly Everest Upgrade ($CI_BRANCH):* upgrading each project to its latest version breaks the build\n$versions"
        MsgToSlack="$msg"
        echo $MsgToSlack >$slack_file
        return 255
    else
        # Life is good, record new revisions and commit.
        msg=":white_check_mark: *Nightly Everest Upgrade ($CI_BRANCH):* upgrading each project to its latest version works!\n$versions"
        MsgToSlack="$msg"
        git checkout $CI_BRANCH &&
            git pull &&
            ./everest --yes snapshot &&
            git commit -am "[CI] automatic upgrade" &&
            git push git@github.com:project-everest/everest.git $CI_BRANCH ||
            MsgToSlack="$msg\n\n:no_entry: *Nightly Everest Upgrade:* could not push fresh commit on branch $CI_BRANCH"

        echo $MsgToSlack >$slack_file
    fi
}

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
            if [[ "$OS" == "Windows_NT" ]]; then
                everest_move && echo true >$status_file
            else
                echo "Invalid target"
            fi
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
export OTHERFLAGS="--print_z3_statistics --use_hints --query_stats"
export MAKEFLAGS="$MAKEFLAGS -Otarget"

exec_build
