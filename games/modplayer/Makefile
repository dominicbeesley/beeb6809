TARGETS_BEEB=	modplay09.hex loadgame.noi
include		../../Makefile.defs

ASFLAGS=-3 -v

$(CHIPKITOUT)/loadgame.noi:	$(CHIPKITOUT)/modplay09.hex
		./makeloadnoi.sh $(CHIPKITOUT)/loadgame.noi
		cat $(CHIPKITOUT)/loadgame.noi $(CHIPKITOUT)/modplay09.sym > $(CHIPKITOUT)/loadgameandsyms.noi
		echo "REG PC \$$1900" >> $(CHIPKITOUT)/loadgameandsyms.noi

$(BEEBOUT)/loadgame.noi:	$(BEEBOUT)/modplay09.hex
		./makeloadnoi.sh $(BEEBOUT)/loadgame.noi
		cat $(BEEBOUT)/loadgame.noi $(BEEBOUT)/modplay09.sym > $(BEEBOUT)/loadgameandsyms.noi
		echo "REG PC \$$1900" >> $(BEEBOUT)/loadgameandsyms.noi
