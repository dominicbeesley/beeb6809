TARGETS_CHIPKIT=	game.hex loadgame.noi
include		../../Makefile.defs

ASFLAGS=-3 -v

$(CHIPKITOUT)/loadgame.noi:	$(CHIPKITOUT)/game.hex
		./makeloadnoi.sh
		cat loadgame.noi $(CHIPKITOUT)/game.sym > loadgameandsyms.noi
		echo "REG CC \$$50" >> loadgameandsyms.noi
		echo "REG PC \$$2000" >> loadgameandsyms.noi

