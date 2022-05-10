#!/bin/bash

[ "$(type -t include)" != 'function' ]&&{ include(){ { [ -z "$_IR" ]&&_IR="$PWD"&&cd "$(dirname "${BASH_SOURCE[0]}")"&&include "$1"&&cd "$_IR"&&unset _IR;}||{ local d="$PWD"&&cd "$(dirname "$PWD/$1")"&&. "$(basename "$1")"&&cd "$d";}||{ echo "Include failed $PWD->$1"&&exit 1;};};}

include '../bash-tools/bash-tools/color.sh'

zdevs_finder()
{

    format_highlight="      -c 33         -e bold"
    local fc_highlight=$(getFormatCode $format_highlight)
    format_headers="      -c 75         -e bold"
    local fc_headers=$(getFormatCode $format_headers)
    format_data="      -c white"
    local fc_data=$(getFormatCode $format_data)
    local fc_none=$(getFormatCode -e reset)
    assert_is_set ${fc_highlight}
    assert_is_set ${fc_headers}
    assert_is_set ${fc_data}

    IN=$(ztc3 device discover --raw | sed -e '1,2d' | sed 's/\t/ /' | awk 'BEGIN { OFS = ";" }{print $1, $4, $5}')

    declare -a ZVIDS
    ZVIDS[0]="10C4"
    ZVIDS[1]="1A86"

    declare -a UID_ARR
    declare -a PORT_ARR

    for OUTPUT in $IN
    do
        IFS=';' read -ra VID_UID_PORT <<< "$OUTPUT"
        if [[ "${ZVIDS[*]}" =~ "${VID_UID_PORT[0]}" ]]; then
            if [ "${VID_UID_PORT[2]}" != "" ]; then
                UID_ARR+=(${VID_UID_PORT[1]})
                PORT_ARR+=(${VID_UID_PORT[2]})
            fi
        fi
    done

    if [ ${#UID_ARR[@]} -eq 0 ]; then
        true
    else
        printf "\n${fc_highlight}FOUND ZERYNTH DEVICES:\n"
        (
         printf "${fc_headers}"
         printf ' \tPORT\tUID\n'
         printf "${fc_data}"
         for i in ${!UID_ARR[@]}
         do
            printf ' \t%s\t%s\n' "${PORT_ARR[i]}" "${UID_ARR[i]}"
         done
         printf "${fc_none}\n"
        ) | column -t -s $'\t'
    fi
}

if [ -n "$( echo $- | grep i )" ]; then
	(LC_ALL=C zdevs_finder "$1")
fi
unset zdevs_finder