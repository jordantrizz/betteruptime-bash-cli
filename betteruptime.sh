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

Betteruptime API Credentials should be placed in \$HOME/.cloudflare
  BU_KEY=\"\"

Version: $VERSION
"

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

# -- betteruptime-api <$API_PATH>
betteruptime-api() {
	local $API_PATH	
	API_PATH=$1

	CURL_OUTPUT=$(curl -s --request GET \
		 --url https://betteruptime.com/${API_PATH} \
  	     --header 'Authorization: Bearer "'${BU-KEY}'"')
  	_debug "$CURL_OUTPUT" 	     
	CURL_OUTPUT_JQ=$(echo $CURL_OUTPUT | jq -r)
    return $CURL_OUTPUT_JQ  	
}

# -- betteruptime-api-creds
betteruptime-api-creds() {
	if [[ -f ~/.betteruptime ]]; then
		_debug "Found $HOME/.betteruptime"
	    source $HOME/.betteruptime
	else
		usage
	    _error "Can't find $HOME/.cloudflare exiting."	    
	    exit 1
	fi
}

# -- betteruptime-api-test
betteruptime-api-test() {
	betteruptime-api
}

# ------------
# -- Main loop
# ------------

betteruptime-api-creds
betteruptime-api-test


if [[ -z $1 ]];then
	usage
else
	echo "Nothing here yet"
fi