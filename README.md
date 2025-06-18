# bd_crack
Just a stupid and gay little script to simplify cracking breached passwords from [breachdirectory.org](https://breachdirectory.org) using the provided hash and the 5 unhashed characters.

## Usage
1. Requires hashcat and a bash terminal  
2. visit [breachdirectory.org](https://breachdirectory.org) and find the breached password you want
3. copy the provided hash the the 5 unhashed characters of the password
4. optionally select a custom charset for the crackin

Usage: `./bd_crack.sh <hash> <known 5 characters> <optional charset>`  
Optional charset format
* Default charset is luds meaning lower alpha, upper alpha, digits, and symbols+space
    * Mix and match any of the following:
        * `l` = lower case alpha (a-z)
        * `u` = upper case alpha (A-Z)
        * `d` = digit (0-9)
        * `s` = symbols + space (<space>!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~)
        * `h` = lower case hex (0-9a-f)
        * `H` = upper case hex (0-9A-F)
        * `b` = bytes (0x00-0xFF)
    * Example: lower alpha, upper alpha, and digits: `lud` ex. `bash bd_crack.sh c8ea28d3285e468961a76b5de75871fbe539808a passp lud`
    * Example: upper alpha and symbols+space: `us` ex. `bash bd_crack.sh c8ea28d3285e468961a76b5de75871fbe539808a passp us`
* Example: `bash bd_crack.sh c8ea28d3285e468961a76b5de75871fbe539808a passp lud`
* Example: `bash bd_crack.sh c8ea28d3285e468961a76b5de75871fbe539808a passp`