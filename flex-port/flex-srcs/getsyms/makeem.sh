#!/bin/bash

#!/bin/bash

# convert all .org.txt files in current directory to 
# .org.asm files (sorting out spacing etc) for use
# with files cut and paste from the Flex system manuals

export MY_FILE="`readlink -f "$0"`"
export MY_DIR="`dirname "$MY_FILE"`"

source "$MY_DIR/../../scripts/utils.sh"

for x in $MY_DIR/*.TXT; do
	echo $x
	$MY_DIR/../../scripts/TXT2ASM2.pl <$x >$x.org.asm
	checkstat "perl"
	asm6809 -S -o $x.hex /dev/nul --listing=$x.lst $x.org.asm
	checkstat "asm6809"
	$MY_DIR/../../../scripts/getsymbols.pl <$x.lst >$x.sym
	checkstat "getsymbols"
done;