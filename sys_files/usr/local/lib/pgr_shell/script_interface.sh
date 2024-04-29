#!/bin/bash

# ----------------------------------
RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
GRAY='\033[1;30m'
AMBER='\033[0;33m'
NC='\033[0m' # No Color

shout () {
    echo -e "$RED$*$NC" >&2
}

dont_shout () {
    echo -e "$GREEN$*$NC" >&2
}

whisper () {
    echo -e "$GRAY$*$NC" >&2
}

amber_info () {
    echo -e "$AMBER$*$NC" >&2
}

print_command() {
    whisper "${GRAY}Command:$NC"
    whisper "    $@"
}