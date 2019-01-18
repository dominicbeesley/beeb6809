TARGETS_BEEB=	modplay09.hex loadgame.noi
DEPS=		modload.asm modplay.inc
ASFLAGS=-3 -v
include		../../Makefile.defs


#$(CHIPKITOUT)/loadgame.noi:	$(CHIPKITOUT)/modplay09.hex modload.rel
#		./makeloadnoi.sh $(CHIPKITOUT)/loadgame.noi
#		cat $(CHIPKITOUT)/loadgame.noi $(CHIPKITOUT)/modplay09.sym > $(CHIPKITOUT)/loadgameandsyms.noi
#		echo "REG PC modplay_debug" >> $(CHIPKITOUT)/loadgameandsyms.noi

$(BEEBOUT)/loadgame.noi:	$(BEEBOUT)/modplay09.hex 
		./makeloadnoi.sh $(BEEBOUT)/loadgame.noi
		cat $(BEEBOUT)/loadgame.noi $(BEEBOUT)/modplay09.sym > $(BEEBOUT)/loadgameandsyms.noi
		echo "REG PC modplay_debug" >> $(BEEBOUT)/loadgameandsyms.noi


#$(BEEBOUT)/modload.rel:	modload.asm
#		$(AS) $(ASFLAGS) --define MACH_BEEB=1 -B -o $@ -l $(basename $@).lst $<