#!/bin/bash

export MY_FILE="`readlink -f "$0"`"
export MY_DIR="`dirname "$MY_FILE"`"

source "$MY_DIR/utils.sh"

HOSTFSDIR=
HOSTFS=0
DEST=
NAME=

while [[ $# -gt 0 && $1 =~ ^\- ]]; do
  case "$1" in
    "--hostfs") 
      HOSTFS=1;
      HOSTFSDIR="$2";
      shift
      ;;
    "--dest")
      DEST="$2";
      shift;
      ;;
    "--name")
      NAME="$2";
      shift;
      ;;
    *) echo "unknown switch $1";  exit 1 ;;
  esac
  shift;
done;

FOLDER="$1"

if [[ -z "$NAME" ]]; then
  NAME="$1"
fi

if [[ -z "$DEST" ]]; then
  SSD="$name.ssd"
else
  SSD="$DEST"
fi;

if [[ $HOSTFS -gt 0 ]]; then
  HOSTFSDIR="$HOSTFSDIR/$NAME"
  info "copying to hostfs $HOSTFSDIR"
fi;

bold "build ssd for $FOLDER"

if [[ ! -d "$FOLDER" ]]; then
  >&2 echo "No folder $FOLDER";
  exit 2;
fi;

if [[ ! -z "$HOSTFSDIR" && ! -d "$HOSTFSDIR" ]]; then
  mkdir "$HOSTFSDIR"
  checkstat "mkdir $HOSTFSDIR"
fi;



dfs form -80 "$SSD"
checkstat "dfs form -80"

dfs title "$SSD" "`basename "$FOLDER"`"

infs=("$FOLDER"/*.inf)

if [ -e "${infs[0]}" ]; then
  dfs add "$SSD" "$FOLDER"/*.inf
  checkstat "adding *.inf"


  if [[ ! -z "$HOSTFSDIR" ]]; then
    for x in "$FOLDER"/*.inf; do
      f=$(basename "$x")
      cp "$x" "$HOSTFSDIR/$f"
      checkstat "cp \"$x\" \"$HOSTFSDIR/$f\""
      x2="${x%.*}"
      f2=$(basename "$x2")
      if [[ -e "$x2" ]]; then
        cp "$x2" "$HOSTFSDIR/$fn2"
        checkstat "cp \"$x2\" \"$HOSTFSDIR/$fn2\""
      fi
    done;
  fi;
fi

if [[ -e "$FOLDER/include.lst" ]]; then

  info "Reading list file \"$FOLDER/include.lst\""

  while IFS= read -d $'\n' -r line; do
    IFS=' ' read -r f1 start exec bbcfile<<< "$line"
    info "F=$f1 S=$start E=$exec BF=$bbcfile"
    f="`readlink --canonicalize -f "$FOLDER/$f1"`"
    fb="`basename "$f"`"

    fne="${fb%.*}"

    if [[ ! -z "$bbcfile" ]]; then
      fne="$bbcfile"
    fi;


    if [[ ! -e "$f" ]]; then
      warn "Skipping missing $f";
    else
      if [[ "$f" == *.hex ]]; then     
        tmpf=`mktemp`
        checkstat "mktemp"
      	start=`$MY_DIR/hex2bin.pl "$f" "$tmpf"`

      	checkstat "converting hex file $f to binary"
      	if [[ -n "$start" ]]; then
      	  dfs add -l "0x$start" -e "0x$start" -f "$fne" "$SSD" "$tmpf"
      	else
      	  error "Bad hex file?"
      	fi

        if [[ ! -z "$HOSTFSDIR" ]]; then
          fn="${fb%.*}.bin"
          cp "$tmpf" "$HOSTFSDIR/$fn"
          checkstat "cp \"$tmpf\" \"$HOSTFSDIR/$fn\""
          echo "$fne $start $start" > "$HOSTFSDIR/$fn.inf"
        fi;

      	rm "$tmpf"
      else
      	dfs add -l "0x$start" -e "0x$exec" -f "$fne" "$SSD" "$f"

        if [[ ! -z "$HOSTFSDIR" ]]; then
          cp "$f" "$HOSTFSDIR/$fb"
          checkstat "cp \"$f\" \"$HOSTFSDIR/$fb\""
          echo "$fne $start $exec" > "$HOSTFSDIR/$fb.inf"
        fi;        
      fi
    fi;

  done < <(dos2unix < "$FOLDER/include.lst")
fi