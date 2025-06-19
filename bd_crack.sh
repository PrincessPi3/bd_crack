#!/bin/bash
# set -e # Exit immediately if a command exits with a non-zero status.
# Cracking helper for breachdirectory.org
# Usage: ./bd_crack.sh <hash> <known 5 chars> <optional charset>
# Optional charset format:
#       Default charset is luds meaning lower alpha, upper alpha, digits, and symbols+space
#       Mix and match any of the following:
#           l = lower case alpha (a-z)
#           u = upper case alpha (A-Z)
#           d = digit (0-9)
#           s = symbols + space (<space>!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~)
#           h = lower case hex (0-9a-f)
#           H = upper case hex (0-9A-F)
#           b = bytes (0x00-0xFF)
#       Example: lower alpha, upper alpha, and digits: lud ex. bash bd_crack.sh c8ea28d3285e468961a76b5de75871fbe539808a passp lud
#       Example: upper alpha and symbols+space: us ex. bash bd_crack.sh c8ea28d3285e468961a76b5de75871fbe539808a passp us
# Example: bash bd_crack.sh c8ea28d3285e468961a76b5de75871fbe539808a passp lud
# Example: bash bd_crack.sh c8ea28d3285e468961a76b5de75871fbe539808a passp

if [ -z "$1" ] || [ -z "$2" ]; then # check to make sure both required args are present
    echo -e "Mandatory arguments missing!\nPlease see README for more details\nUsage:\n\tbd_crack.sh <hash> <known five characters> <optional charset>\nexiting"
    exit 1 # die on fail after printing usage bullshit :lmao:
fi

if [ ${#1} -ne 40 ]; then # check da length of da hashie boi
    echo -e "First arguement should be the SHA1 hash, exactly 40 hex characters long!\nPlease see README for more details\nUsage:\n\tbd_crack.sh <hash> <known five characters> <optional charset>\nexiting"
    exit 1
fi

if [ ${#2} -ne 5 ]; then # make sure da known chars are precisely 5 chars otherwise fail
    echo -e "Second argument should be exactly five characters!\nPlease see README for more details\nUsage:\n\tbd_crack.sh <hash> <known five characters> <optional charset>\nexiting"
    exit 1
fi

# Initialize charset_formatted early
charset_formatted=""

if [ -n "$3" ]; then # if charset is specified (using -n for non-empty string)
    charset="$3" # just rename $3 for whatever reason lmfao im so high
    valid_charsets="ludhHsb" # regex bit of valid charsssssss

    if [[ "$charset" =~ ^["$valid_charsets"]+$ ]]; then # sanity checkan da stupid chars :wheeze: just some shitty regex bullsh8it
        # Unique and sorted characters, removed newline (as original script did)
        charset=$(grep -o . <<< "$charset" | sort -u | tr -d '\n')
        
        # Construct hashcat's custom charset string (e.g., "?l?u?d")
        for (( i=0; i<${#charset}; i++ )); do
            if [ $i -eq 0 ]; then
                charset_formatted+="?" # Start with '?'
            fi
            charset_formatted+="${charset:$i:1}" # Add current char
            if [ $i -lt $((${#charset}-1)) ]; then
                charset_formatted+="?" # Add '?' between chars
            fi
        done
    else
        echo -e "INVALID CHARSET, DEFAULTING TO DEFAULT CHARSET"
        charset_formatted="?l?u?d?s" # just replicate da default charset here because lazy as fucxk lmafao
    fi
else # if charset is not specified default to digit, upper alpha, lower alpha, and symbols+space
    charset_formatted="?l?u?d?s"
fi

outfile="$2-$1-$(date +"%d-%m-%Y-%H%M")-cracked.txt" # using a fookin outfile because da hashcat.potsmoke or whatever the fuck is stupid

hashcat -a3 -m100 "$1" -1 "$charset_formatted" "$2?1?1?1?1?1?1?1?1" --increment --increment-min=5 -O -o "$outfile"
retcode=$? # jus gettin da return code from hashcat rq

if [ $retcode -eq 0 ]; then # check if hashcat exited with a 0 meaning successful crack
    # THIS IS THE CRITICAL ADDITION: Check if the file ACTUALLY exists
    if [ -f "$outfile" ]; then # Explicitly check if the file was created
        # real_user="${SUDO_USER:-$USER}" # stupid hack to get the real current user regardless of any sudo usage
        # sudo chown "$real_user":"$real_user" "$outfile" # fix da fuckin perms jfc lmao

        echo -e "\nCracked! Result:\n\t$(cat "$outfile")\n" # show da contents of da outfile for helpfuls

        echo "Cracked Successfully! Password will be in ./${outfile}!"
    else
        # Hashcat returned 0, but no file. This means no crack was found.
        echo "Stopped or Ended! Password not found within the specified mask/charset. Hashcat completed without errors."
        echo "Output file '$outfile' was not created because no crack was found."
        exit 1 # Exit with an error
    fi
else # otherwise inform of failure (hashcat returned a non-zero error code)
    echo "Hashcat encountered an error or was stopped unexpectedly (exit code: $retcode)."
    echo "Please review hashcat's output above for details."
    exit 1 # Exit with an error
fi