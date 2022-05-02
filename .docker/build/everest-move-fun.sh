function everest_move() {
    [[ -n "$DZOMO_GITHUB_TOKEN" ]] || return 1
    git config --global user.name "Dzomo, the Everest Yak"
    git config --global user.email "everbld@microsoft.com"

    # Work around `git pull` getting stuck
    # From https://askubuntu.com/questions/336907/really-verbose-way-to-test-git-connection-over-ssh
    export GIT_SSH_COMMAND='ssh -vvv'

    # Build feedback, e.g. do we need to push the docker container
    has_jq=false
    if which jq ; then
        has_jq=true
    fi
    if $has_jq ; then
        jq -n > $build_feedback
    fi

    function feedback() {
        if $has_jq ; then
            jq 'setpath(["'"$1"'"];'"$2"')' < $build_feedback > $build_feedback.tmp
            mv $build_feedback.tmp $build_feedback
        fi
    }

    # Figure out the branch
    CI_BRANCH=${branchname##refs/heads/}
    echo "Current branch_name=$CI_BRANCH"

    # This function is called from a test... so it needs to fast-fail because "set
    # -e" does not apply within subshells.

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
            versions="$versions\n    *($r)* <$url|moves to $(git rev-parse HEAD | cut -c 1-8)> on branch ${branches[$r]}"
        else
            versions="$versions\n    *($r)* stays at $(git rev-parse HEAD | cut -c 1-8) on branch ${branches[$r]}"
        fi
        cd ..
    done
    # Once the HACL* version has been upgraded, this determines the Vale version
    # we need.
    ./everest get_vale

    versions="$versions\n"
    echo "Versions content: $versions"

    local msg=""
    local everest_args
    if [[ "$OS" == "Windows_NT" ]]; then
        everest_args="-windows pull_vale make test verify drop qbuild"
    else
        everest_args="pull_vale make test verify"
    fi
    if ! $fresh; then
        # Bail out early if there's nothing to do
        MsgToSlack=":information_source: *Nightly Everest Upgrade ($CI_BRANCH):* nothing to upgrade"
        echo "MsgToSlack content: $MsgToSlack"
        echo $MsgToSlack >$slack_file
        feedback SkipDockerImagePush true
    elif ! ./everest --yes -j $threads $everest_args; then
        # Provide a meaningful summary of what we tried
        msg=":no_entry: *Nightly Everest Upgrade ($CI_BRANCH):* upgrading each project to its latest version breaks the build\n$versions"
        MsgToSlack="$msg"

        echo "MsgToSlack content: $MsgToSlack"
        echo $MsgToSlack >$slack_file
        return 255
    else
        # Life is good, record new revisions and commit.
        msg=":white_check_mark: *Nightly Everest Upgrade ($CI_BRANCH):* upgrading each project to its latest version works!\n$versions"
        MsgToSlack="$msg\n\n:no_entry: *Nightly Everest Upgrade:* could not push fresh commit on branch $CI_BRANCH"
        git checkout $CI_BRANCH &&
            git pull &&
            ./everest --yes snapshot &&
            git commit -am "[CI] automatic upgrade" &&
            git push https://"$DZOMO_GITHUB_TOKEN"@github.com/project-everest/everest.git $CI_BRANCH &&
        MsgToSlack="$msg"

        echo "MsgToSlack content: $MsgToSlack"
        echo $MsgToSlack >$slack_file
        if [[ $MsgToSlack = *"could not push fresh commit on branch"* ]]; then
            return 255
        fi
    fi
}
