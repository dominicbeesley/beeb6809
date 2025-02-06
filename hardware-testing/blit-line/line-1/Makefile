TARGETS_BEEB=	line-1.hex line-1.noi
CLEAN_EXTRA= $(BEEBOUT)/loadgame.noi

include		../../../Makefile.defs

ASFLAGS=-v

$(BEEBOUT)/line-1.noi:	$(BEEBOUT)/line-1.hex
		echo "LOAD $(shell $(WINPATH) $(BEEBOUT)/line-1.hex)" > $(BEEBOUT)/loadgame.noi
		echo 'REG PC $$2000' >> $(BEEBOUT)/loadgame.noi

