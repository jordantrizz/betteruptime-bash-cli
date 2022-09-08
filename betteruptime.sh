#!/bin/bash

# ------------
# -- Variables
# ------------
VERSION=0.0.1
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DEBUG="0"

# -- Colors
RED="\e[31m"
GREEN="\e[32m"
BLUEBG="\e[44m"
YELLOWBG="\e[43m"
GREENBG="\e[42m"
DARKGREYBG="\e[100m"
ECOL="\e[0m"

# -------
# -- Help
# -------
USAGE=\
"$0 <command>

Version: $VERSION"

# ------------
# -- Functions
# ------------

# -- _error
_error () {
    echo -e "${RED}** ERROR ** - $@ ${ECOL}"
}

_success () {
    echo -e "${GREEN}** SUCCESS ** - $@ ${ECOL}"
}

_running () {
    echo -e "${BLUEBG}${@}${ECOL}"
}

_creating () {
    echo -e "${DARKGREYBG}${@}${ECOL}"
}

_separator () {
    echo -e "${YELLOWBG}****************${ECOL}"
}

_debug () {
    if [ -f $SCRIPT_DIR/.debug ]; then
        echo "DEBUG: $@"
    fi
}

_debug_json () {
    if [ -f $SCRIPT_DIR/.debug ]; then
        echo $@ | jq
    fi
}

usage () {
    echo "$USAGE"
}

# ------------
# -- Main loop
# ------------

if [[ -z $1 ]];then
	usage
else
	echo "Nothing here yet"
fi