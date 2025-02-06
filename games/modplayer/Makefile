TARGETS_BEEB=	modplay09.hex modplay09.bin loadgame.noi 
DEPS=		modload.asm modplay.inc common.inc helptext.mo7.txt
ASFLAGS=-3 -v



include		../../Makefile.defs


$(BEEBOUT)/loadgame.noi:	$(BEEBOUT)/modplay09.bin
		cat "LOAD $(shell $(WINPATH) $(BEEBOUT)/modplay09.hex)" > $(BEEBOUT)/loadgame.noi
		cat $(BEEBOUT)/loadgame.noi $(BEEBOUT)/modplay09.sym > $(BEEBOUT)/loadgameandsyms.noi
		echo "REG PC modplay_debug" >> $(BEEBOUT)/loadgameandsyms.noi
		