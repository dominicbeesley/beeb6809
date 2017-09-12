#!/bin/bash
perl fixupdispatchtable.pl <6809BAS.asm >6809BAS.asm2
if [[ "$?" -ne "0" ]]; then
	exit -1;
fi

diff --ignore-trailing-space 6809BAS.asm 6809Bas.asm2
