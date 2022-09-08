#!/bin/bash

# ------------
# -- Variables
# ------------
VERSION=0.0.1
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SCRIPT=betteruptime
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
USAGE_FOOTER=\
"Version: $VERSION
Type $SCRIPT help for more."

USAGE=\
"$SCRIPT [-a <apikey>|-d] <command>

Commands:
	test			 - Test Better Uptime API key.
	list             - List objects
	create           - Create object

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

${USAGE_FOOTER}
"

USAGE_LIST=\
"$SCRIPT [-a <apikey>|-d] list <object>

Objects:
	monitors         - Create monitor.
	heartbeat        - Create Heartbeat.

${USAGE_FOOTER}
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
    if [[ -f $SCRIPT_DIR/.debug ]] || [[ $DEBUG == "1" ]]; then
        echo -e "${CYAN}** DEBUG: $@${ECOL}"
    fi
}

_debug_json () {
    if [ -f $SCRIPT_DIR/.debug ]; then
        echo $@ | jq
    fi
}

usage () {
	if [[ -z $1 ]]; then
	    echo "$USAGE"
	else
		USAGE_TEXT="USAGE_${1}"
		echo "${!USAGE_TEXT}"
	fi
}

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
    -j|--json)
    JSON_OUTPUT="1"
    _debug "\$JSON_OUTPUT: $JSON_OUTPUT"
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# -- betteruptime-api <$API_PATH>
betteruptime-api() {
	_debug "Running betteruptime-api() with $@"
	local $API_PATH	
	API_PATH=$1

	#if [[ $DEBUG == "1" ]];then set +x;fi
	CURL_OUTPUT=$(curl -s --request GET \
		 --url "https://betteruptime.com${API_PATH}" \
		 --header 'Authorization: Bearer '"${BU_KEY}"'')
	#if [[ $DEBUG == "1" ]];then set -x;fi
	
	CURL_EXIT_CODE="$?"
	if [[ $CURL_EXIT_CODE -ge "1" ]]; then
		_error "Error from API: ${CURL_EXIT_CODE}"
		return 1
	elif [[ $CURL_OUTPUT == *"error"* ]]; then
		_error "Error from API: $CURL_OUTPUT"	
		_debug "$CURL_OUTPUT"
		return 1
	else
	 	_debug "Success from API: $CURL_OUTPUT"
	 	_debug "$CURL_OUTPUT"
	fi
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
	_debug "\$CURL_EXIT_CODE: $CURL_EXIT_CODE"
	if [[ $CURL_EXIT_CODE -ge "1" ]]; then
        _error "Better Uptime API connection not working!"
        exit 1
	else
		_success "Better Uptime API connection working!"
		exit 0
	fi
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

# -- commands
CMD1=$1
_debug "\$CMD1:$CMD1"
shift
    case "$CMD1" in
        # -- usage
        help)
		usage
		exit
        ;;

		# -- test
        test)
        betteruptime-api-test
		;;
		
        # -- list
        list)
        CMD2=$1
        _debug "\$CMD2:$CMD2"
        shift
        	case "$CMD2" in
        		# -- monitors
        		monitors)
					betteruptime-api /api/v2/monitors
        			if [[ $JSON_OUTPUT == "1" ]]; then
						echo $CURL_OUTPUT
						exit
					else
						_running "Listing monitors"
						_debug "Outputting clean"
						PARSED_OUTPUT=$(echo $CURL_OUTPUT | jq -r '(["ID","MONITOR_TYPE","URL","PRONAME","GROUP","STATUS"] |
							(., map(length*"-"))),
							(.data[] | [ .id,
							.attributes["monitor_type"],
							.attributes["url"],
							.attributes["pronounceable_name"],
							.attributes["monitor_group_id"],
							.attributes["status"]
							])|join(",")' | column -t -s ',')
						HEADER_OUTPUT=$(printf "$PARSED_OUTPUT" | awk 'FNR <= 2')
						printf "$PARSED_OUTPUT" | awk -v h="$HEADER_OUTPUT" '{print}; NR % 10 == 0 {print "\n" h}'
						exit
					fi
        		;;
        		heartbeats)
        		echo "heartbeats"
        		exit
        		;;
        		*)
        		usage LIST
        		exit 1
        	esac
        ;;

		# -- add
        add)
		echo "add"
        ;;

		# -- catchall
        *)
        usage
        _error "No command specified"
        exit 1
        ;;
esac