TARGETS=	game.hex loadgame.noi
include		../../Makefile.defs

ASFLAGS=-3 -v

loadgame.noi:	game.hex
		./makeloadnoi.sh
		cat loadgame.noi game.sym > loadgameandsyms.noi
		echo "REG CC \$$50" >> loadgameandsyms.noi
		echo "REG PC \$$2000" >> loadgameandsyms.noi

