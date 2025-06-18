#!/bin/bash
# Cracking helper for breachdirectory.org
# Usage: ./bd_crack.sh <hash> <known 5 chars> <optional charset>
# Optional charset format:
#     Default charset is luds meaning lower alpha, upper alpha, digits, and symbols+space
#     Mix and match any of the following:
#           l = lower case alpha (a-z)
#           u = upper case alpha (A-Z)
#           d = digit (0-9)
#           s = symbols + space (<space>!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~)
#           h = lower case hex (0-9a-f)
#           H = upper case hex (0-9A-F)
#           b = bytes (0x00-0xFF)
#         Example: lower alpha, upper alpha, and digits: lud ex. bash bd_crack.sh c8ea28d3285e468961a76b5de75871fbe539808a passp lud
#         Example: upper alpha and symbols+space: us ex. bash bd_crack.sh c8ea28d3285e468961a76b5de75871fbe539808a passp us
# Example: bash bd_crack.sh c8ea28d3285e468961a76b5de75871fbe539808a passp lud
# Example: bash bd_crack.sh c8ea28d3285e468961a76b5de75871fbe539808a passp

if [ -z $1 -o -z $2 ]; then # check to maek sure both required args are present
    echo -e "Mandatory arguments missing! Usage:\nbd_crack.sh <hash> <known five characters> <optional charset>\nPlease see README for more details"
    exit # die on fail after printing usage bullshit :lmao:
fi

if [ ! -z $3 ]; then # if charset is specified
    charset="$3" # just rename $3 for whatever reason lmfao im so high
    charset_formatted="?" # start with da ? at the start frong
    valid_charsets="ludhHsb" # regex bit of valid charsssssss

    if [[ "$charset" =~ ^["$valid_charsets"]+$ ]]; then # sanity checkan da stupid chars :wheeze:
        charset=$(grep -o . <<< "$charset" | sort -u | tr -d '\n')
        echo $charset
    else
        echo "INVALID CHARSET, DEFAULTING TO DEFAULT BEHAVIOR"
        charset_formatted="?l?u?d?s" # just replicate da default charset here because lazy as fucxk lmafao
    fi

    for (( i=0; i<${#charset}; i++ )); do
        charset_formatted+="${charset:$i:1}"  # add current char to charset_formatted
        
        # add ? after each character except da last char in da string
        if [ $i -lt $((${#charset}-1)) ]; then
            charset_formatted+="?"
        fi

    done
else # if charset is not specified default to digit, upper alpha, lower alpha, and symbols+space
    charset_formatted="?l?u?d?s"
fi

sudo hashcat -a3 -m100 $1 -1 $charset_formatted "$2?1?1?1?1?1?1?1?1" --increment --increment-min=5 -O
