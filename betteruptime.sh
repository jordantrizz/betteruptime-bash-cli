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
CYAN="\e[36m"
BLUEBG="\e[44m"
YELLOWBG="\e[43m"
GREENBG="\e[42m"
DARKGREYBG="\e[100m"
ECOL="\e[0m"

# -------
# -- Help
# -------
USAGE=\
"$0 [-a <apikey>|-d] <command>

Commands:
	test			 - Test Better Uptime API key.
	list             - List Monitors
	create           - Create Monitors

Options:
    -a               - Better Uptime apikey team (Optional)
    -d               - Debug mode (Optional)

API Key:
    The Better Uptime API Credentials should be placed in \$HOME/.cloudflare
    Since there is a separate API key for teams, you can set a default and set
    a team API key. The format as follows.

	Default API Key:  BU_KEY=\"\"
    Team API Key:     TEAM_BU_KEY=\"\"
    
    Replace TEAM with your placeholder and pass \"-a TEAM\" option. If -a isn't
    set then the default BU_KEY is used.

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
        echo -e "${CYAN}** DEBUG: $@${ECOL}"
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
	_debug "\$API_PATH: $API_PATH"

#    if [[ $DEBUG == "1" ]];then set +x;fi
	CURL_OUTPUT=$(curl -s --request GET \
		 --url "https://betteruptime.com${API_PATH}" \
		 --header 'Authorization: Bearer '"${BU_KEY}"'')
#    if [[ $DEBUG == "1" ]];then set -x;fi
  	_debug "$CURL_OUTPUT" 	     
	echo ${CURL_OUTPUT} | jq -r 
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
	betteruptime-api /api/v2/monitors
}

# ------------
# -- Main loop
# ------------

# -- check better uptime credentials
betteruptime-api-creds

# -- check if parameters are set
_debug "PARAMS: $@"
if [[ -z $1 ]];then
	usage
	exit 1
fi

# -- options
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -a|--apikey)
    API_KEY_TEAM="$2"
    _debug "\$API_KEY_TEAM: $API_KEY_TEAM"
    shift # past argument
    shift # past value
    ;;
    -d|--debug)
    DEBUG="1"
    _debug "\$DEBUG: $DEBUG"
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters
