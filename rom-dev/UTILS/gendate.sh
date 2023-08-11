#!/bin/bash

cat <<EOF >$1
VERSION_DATE	MACRO
		FCB	"$(date +%Y-%m-%d,%H%M)"
		ENDM
EOF