TARGETS_CHIPKIT=	game.hex loadgame.noi
include		../../Makefile.defs

ASFLAGS=-3 -v

$(CHIPKITOUT)/loadgame.noi:	$(CHIPKITOUT)/game.hex
		echo "LOAD $(shell $(WINPATH) $(CHIPKITOUT)/game.hex)" > $(CHIPKITOUT)/loadgame.noi
		cat $(CHIPKITOUT)/loadgame.noi $(CHIPKITOUT)/game.sym > $(CHIPKITOUT)/loadgameandsyms.noi
		echo "REG CC \$$50" >> $(CHIPKITOUT)/loadgameandsyms.noi
		echo "REG PC \$$2000" >> $(CHIPKITOUT)/loadgameandsyms.noi

