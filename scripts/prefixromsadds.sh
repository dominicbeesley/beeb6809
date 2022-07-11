#!/bin/bash
FILE=$1
ROMNO=$2

if [[ ! -z "$1" ]]; then
	echo -e "$(cat "$FILE" | perl -e "while (<>) { s/^(DEF\\s+[0-9A-Za-z_]+\\s+)([89AB][0-9A-F]{3})/\${1}$ROMNO:\\2/; print \"\$_\";}")" > "$FILE"
fi
