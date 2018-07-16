#!/bin/bash

# convert all .org.txt files in current directory to 
# .org.asm files (sorting out spacing etc) for use
# with files cut and paste from the Flex system manuals

export MY_FILE="`readlink -f "$0"`"
export MY_DIR="`dirname "$MY_FILE"`"

source "$MY_DIR/utils.sh"


while [[ $# -gt 0 && $1 =~ ^\- ]]; do
  case "$1" in
    *) echo "unknown switch $1";  exit 1 ;;
  esac
  shift;
done;

bold "Converting *.org.txt to *.org.asm"

for x in *.org.txt; do
  x2="${x%.org.txt}.org.asm"
  info "$x => $x2"
  perl "${MY_DIR}/TXT2ASM.pl" <$x >$x2
  checkstat "running ${MY_DIR}/TXT2ASM.pl"

done;