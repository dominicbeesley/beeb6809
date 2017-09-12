#!/bin/bash

export MY_FILE="`readlink -f "$0"`"
export MY_DIR="`dirname "$MY_FILE"`"

source "$MY_DIR/utils.sh"

FOLDER="$1"
SSD="$1.ssd"

bold "build ssd for $FOLDER"

if [[ ! -d "$FOLDER" ]]; then
  >&2 echo "No folder $FOLDER";
  exit 2;
fi;

dfs form -80 "$SSD"
checkstat "dfs form -80"

dfs title "$SSD" "`basename "$FOLDER"`"

dfs add "$SSD" "$FOLDER"/*.inf
checkstat "adding *.inf"

if [[ -e "$FOLDER/include.lst" ]]; then
  while IFS= read -d $'\n' -r line; do
    f="`readlink --canonicalize -f "$FOLDER/$line"`"
    if [[ ! -e "$f" ]]; then
      warn "Skipping missing $f";
    else
      if [[ "$f" == *.hex ]]; then     
        tmpf=`mktemp`
        checkstat "mktemp"
      	start=`$MY_DIR/hex2bin.pl "$f" "$tmpf"`
      	checkstat "converting hex file $f to binary"
      	if [[ -n "$start" ]]; then
      	  dfs add -l "0x$start" -e "0x$start" -f "`basename "$f"`" "$SSD" "$tmpf"
      	else
      	  error "Bad hex file?"
      	fi
      	rm "$tmpf"
      else
      	dfs add -l "0x$start" -e "0x$start" -f "`basename "$f"`" "$SSD" "$f"
      fi
    fi;

  done < <(dos2unix < "$FOLDER/include.lst")
fi