ASFLAGS=-v
TARGETS=
TARGETS_BEEB=	flex-mini-mos-noice.bin  \
		minimos-load.hex


include		../../Makefile.defs

DEPS=../../includes/hardware.inc ../../includes/common.inc ../../includes/mosrom.inc ../../includes/noice.inc 

CLEAN_EXTRA=$(addprefix $(BEEBOUT)/,flex-mini-mosloadandrun.noi flex-mini-mosloadandsyms.noi \
	 flex-mini-mosloadandsymsrun.noi flex-mini-mos-noice.bin flex-mini-mos-noice.sym flex-mini-mos-noice.lst)

#mosrom.bin:		mosrom.asm $(DEPS)
#			$(AS) $(ASFLAGS) --define NOICE=0 -o $@ -l $(basename $@).lst $<



$(BEEBOUT)/flex-mini-mos-noice.bin:	flex-mini-mos.asm $(DEPS) ../../mos/noice/noice/mon-noice-6309-beeb-ovr.ovr $(BEEBOUT)/minimos-load.hex
			./mkversion.sh
			$(AS) -v -3 --define NOICE=1 --define CPU_6809=1 --define MACH_BEEB=1 -o $@ -l $(basename $@).lst $<
			perl ../../scripts/getsymbols.pl <$(basename $@).lst >$(basename $@).sym
						

			echo "L $(shell $(WINPATH) $(BEEBOUT)/flex-mini-mos-noice.bin) 1100 B" >$(BEEBOUT)/flex-mini-mosloadandrun.noi
			echo "L $(shell $(WINPATH) $(BEEBOUT)/minimos-load.hex)" >>$(BEEBOUT)/flex-mini-mosloadandrun.noi
			cat $(basename $@).sym >>$(BEEBOUT)/flex-mini-mosloadandrun.noi
			echo "GO 0F00" >>$(BEEBOUT)/flex-mini-mosloadandrun.noi


