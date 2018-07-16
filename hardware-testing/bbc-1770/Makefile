TILECUT=/cygdrive/d/work/vs2017/AuthorityFileLtd/Games/TileCutter/TileCutter/bin/Debug/TileCutter.exe

CLEAN_EXTRA= 

TARGETS_BEEB=	bbc-1770.hex loadbbc-1770.noi
include		../../Makefile.defs

ASFLAGS=-3 -v

$(BEEBOUT)/loadbbc-1770.noi:	$(BEEBOUT)/bbc-1770.hex
		./makeloadnoi.sh $(BEEBOUT)/loadbbc-1770.noi
		cat $(BEEBOUT)/loadbbc-1770.noi $(BEEBOUT)/bbc-1770.sym > $(BEEBOUT)/loadbbc-1770andsyms.noi
		echo "REG PC \$$1900" >> $(BEEBOUT)/loadbbc-1770andsyms.noi

		