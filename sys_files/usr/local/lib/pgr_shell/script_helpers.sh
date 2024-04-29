#!/bin/bash

check_git_changes(){
    changes=$(git status -s | wc -l)
    if [ $changes -ne 0 ]; then
        shout "WARNING: There are uncommited changes in the repository"
        return 1
    fi
}
