#!/bin/bash

cat <<EOF >VERSION-date.gen.asm
VERSION_DATE	MACRO
		FCB	"$(date +%Y-%m-%d)"
		ENDM
EOF