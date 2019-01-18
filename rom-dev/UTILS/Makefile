ASFLAGS=-v -3 
TARGETS_BEEB=	UTILS.bin \
		loadUTILSandsyms.noi \
		loadUTILS.noi 

DEPS=	../../includes/hardware.inc \
		../../includes/common.inc \
		../../includes/mosrom.inc \
		../../includes/noice.inc \
		../../includes/oslib.inc \
		../../mos/noice/noice/mon-noice-6309-beeb-debug.ovr \
		VERSION-date.gen.asm \
		Makefile

ROMNO=E

include		../../Makefile.defs 

VERSION-date.gen.asm: UTILS.asm
		./gendate.sh		

$(BEEBOUT)/loadUTILSandsyms.noi $(BEEBOUT)/loadUTILS.noi: $(BEEBOUT)/UTILS.bin $(BEEBOUT)/UTILS.sym
		../../scripts/prefixromsadds.sh $(BEEBOUT)/UTILS.sym $(ROMNO)
		./makeloadnoi.sh $(BEEBOUT)/UTILS.bin $(BEEBOUT)/loadUTILS.noi $(ROMNO)
		cat $(BEEBOUT)/loadUTILS.noi $(BEEBOUT)/UTILS.sym $(BEEBOUT)/../../mos/beeb6809-mos/mosrom.sym >$(BEEBOUT)/loadUTILSandsyms.noi
		echo -e "WAITFORSTOP 1\nR PC mos_handle_res\n" >>$(BEEBOUT)/loadUTILSandsyms.noi



$(BEEBOUT)/UTILS.bin: $(DEPS)
