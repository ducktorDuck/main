#!/bin/bash

function kill_processes_that_match_arguments()
{
    arg=("$@")
    unset PIDS_TO_BE_KILLED

    for ((i=0;i<$#;i++))
    do
        unset MORE_PIDS_TO_KILL
        MORE_PIDS_TO_KILL=$( ps gaux | grep "${arg[i]}" | grep -v 'grep' | awk '{ print $2 }' )
        if [[ $MORE_PIDS_TO_KILL ]]; then
            PIDS_TO_BE_KILLED="$MORE_PIDS_TO_KILL $PIDS_TO_BE_KILLED"
        fi
    done

    if [[ $PIDS_TO_BE_KILLED ]]; then
        kill -SIGKILL $PIDS_TO_BE_KILLED
        echo 'Killed processes:' $PIDS_TO_BE_KILLED
    else
        echo 'No processes were killed.'
    fi
}

KILL_THESE_PROCESSES=('a.single.word.argument' 'a multi-word argument' '/some/other/argument' 'yet another')
kill_processes_that_match_arguments "${KILL_THESE_PROCESSES[@]}"
