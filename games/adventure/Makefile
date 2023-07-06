TILECUT=/cygdrive/d/work/vs2017/AuthorityFileLtd/Games/TileCutter/TileCutter/bin/Debug/TileCutter.exe

CLEAN_EXTRA= \
				tiles/charac.til \
				tiles/main.pal \
				gen-vars.inc

TARGETS_BEEB=	game.hex adventure.ssd loadgame.noi
include		../../Makefile.defs

ASFLAGS=-3 -v

$(BEEBOUT)/adventure.ssd: ssd/include.lst tiles $(BEEBOUT)/game.hex maps/home.bin
	../../scripts/buildssd.sh --dest $(BEEBOUT)/adventure.ssd --hostfs ~/hostfs --name adventure ./ssd

game.asm: tiles

tiles:	tiles/charac.til \
		tiles/main.pal \
		tiles/over-back.til \
		tiles/over-back.til.cuts \
		tiles/over-front.til \
		tiles/over-front.til.cuts \
		gen-vars.inc

tiles/charac.til tiles/main.pal gen-vars.inc over-back.til over-back.til.cuts over-front.til over-front.til.cuts: \
		src-graphics/cave.png \
		src-graphics/character.png \
		src-graphics/Overworld.png \
		src-graphics/objects.png \
		src-graphics/tile-cutter.xml

		-mkdir -p tiles
###		$(TILECUT) "$(shell cygpath -w "src-graphics/tile-cutter.xml")"
## TODO: Grab new tilecut from 6502

		echo -n -e "CHARAC_SPR_LEN\tequ\t" > gen-vars.inc
		stat -c%s tiles/charac.til >> gen-vars.inc
		echo -n -e "BACK_SPR_LEN\tequ\t" >> gen-vars.inc
		stat -c%s tiles/over-back.til >> gen-vars.inc
		echo -n -e "FRONT_SPR_LEN\tequ\t" >> gen-vars.inc
		stat -c%s tiles/over-front.til >> gen-vars.inc


maps/home.bin: maps/home.tmx tiles
		scripts/makemaps.pl maps/home.tmx tiles/over-back.til.cuts tiles/over-front.til.cuts maps/home.bin

$(BEEBOUT)/loadgame.noi:	$(BEEBOUT)/game.hex
		cat "LOAD $(shell $(WINPATH) $(BEEBOUT)/game.hex)" > $(BEEBOUT)/loadgame.noi
		cat $(BEEBOUT)/loadgame.noi $(BEEBOUT)/game.sym > $(BEEBOUT)/loadgameandsyms.noi
		echo "REG PC \$$E00" >> $(BEEBOUT)/loadgameandsyms.noi

		