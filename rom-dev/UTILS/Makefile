ASFLAGS=-v
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
		bltutil_jimstuff.asm \
		bltutil_jimstuff.inc \
		bltutil_utils.asm \
		bltutil_cfg.asm \
		bltutil_flashutils.asm \
		bltutil_vnula.asm \
		bltutil_romheader.asm \
		bltutil_heap.asm \
		bltutil_sound.asm \
		bltutil_noice.asm \
		bltutil.inc \
		Makefile

ROMNO=E
HOSTFSDIR=~/hostfs/roms69/

include		../../Makefile.defs 

.PHONY:	hostfs
hostfs: $(filter %.bin, $(addprefix $(HOSTFSDIR)/, $(TARGETS_BEEB)))

$(HOSTFSDIR)/%.bin: $(BEEBOUT)/%.bin
	cp $< $@


VERSION-date.gen.asm: UTILS.asm $(DEPS)
		./gendate.sh		

$(BEEBOUT)/loadUTILSandsyms.noi $(BEEBOUT)/loadUTILS.noi: $(BEEBOUT)/UTILS.bin $(BEEBOUT)/UTILS.sym
		../../scripts/prefixromsadds.sh $(BEEBOUT)/UTILS.sym $(ROMNO)
		./makeloadnoi.sh $(BEEBOUT)/UTILS.bin $(BEEBOUT)/loadUTILS.noi $(ROMNO)
		cat $(BEEBOUT)/loadUTILS.noi $(BEEBOUT)/UTILS.sym $(BEEBOUT)/../../mos/beeb6809-mos/mosrom.sym >$(BEEBOUT)/loadUTILSandsyms.noi
		echo -e "WAITFORSTOP 1\nR PC mos_handle_res\n" >>$(BEEBOUT)/loadUTILSandsyms.noi



$(BEEBOUT)/UTILS.bin: $(DEPS)
