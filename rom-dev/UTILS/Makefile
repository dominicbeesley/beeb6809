ASFLAGS=-v
TARGETS_BEEB=	UTILS.bin \
		loadUTILSandsyms.noi \
		loadUTILS.noi 

TARGETS_SBC09=	UTILS.bin \
		loadUTILSandsyms.noi \
		loadUTILS.noi 

DEPS_B=	../../includes/hardware.inc \
		../../includes/common.inc \
		../../includes/mosrom.inc \
		../../includes/noice.inc \
		../../includes/oslib.inc \
		../../mos/noice/noice/mon-noice-6309-beeb-debug.ovr \
		VERSION-date.gen.beeb.asm \
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

DEPS_S=	../../includes/hardware.inc \
		../../includes/common.inc \
		../../includes/mosrom.inc \
		../../includes/oslib.inc \
		VERSION-date.gen.sbc09.asm \
		bltutil_utils.asm \
		bltutil_cfg.asm \
		bltutil_flashutils.asm \
		bltutil_vnula.asm \
		bltutil_romheader.asm \
		bltutil.inc \
		Makefile


ROMNO=F
HOSTFSDIR_B=~/hostfs/beebroms/
HOSTFSDIR_S=~/hostfs/beebroms/

include		../../Makefile.defs 

.PHONY:	hostfs
hostfs: $(filter %.bin, $(addprefix $(HOSTFSDIR_B)/, $(TARGETS_BEEB))) $(filter %.bin, $(addprefix $(HOSTFSDIR_S)/, $(TARGETS_SBC09)))

$(HOSTFSDIR_B)/%.bin: $(BEEBOUT)/%.bin
	cp $< $@

$(HOSTFSDIR_S)/%.bin: $(SBC09OUT)/%.bin
	cp $< $@

VERSION-date.gen.beeb.asm: UTILS.asm $(DEPS_B)
		./gendate.sh $@

VERSION-date.gen.sbc09.asm: UTILS.asm $(DEPS_S)
		./gendate.sh $@	


$(BEEBOUT)/loadUTILSandsyms.noi $(BEEBOUT)/loadUTILS.noi: $(BEEBOUT)/UTILS.bin $(BEEBOUT)/UTILS.sym
		../../scripts/prefixromsadds.sh $(BEEBOUT)/UTILS.sym $(ROMNO)
		./makeloadnoi.sh $(BEEBOUT)/UTILS.bin $(BEEBOUT)/loadUTILS.noi $(ROMNO)
		cat $(BEEBOUT)/loadUTILS.noi $(BEEBOUT)/UTILS.sym $(BEEBOUT)/../../mos/beeb6809-mos/mosrom.sym >$(BEEBOUT)/loadUTILSandsyms.noi
		echo -e "WAITFORSTOP 1\nR PC mos_handle_res\n" >>$(BEEBOUT)/loadUTILSandsyms.noi

$(SBC09OUT)/loadUTILSandsyms.noi $(SBC09OUT)/loadUTILS.noi: $(SBC09OUT)/UTILS.bin $(SBC09OUT)/UTILS.sym
		../../scripts/prefixromsadds.sh $(SBC09OUT)/UTILS.sym $(ROMNO)
		./makeloadnoi.sh $(SBC09OUT)/UTILS.bin $(SBC09OUT)/loadUTILS.noi $(ROMNO)
		cat $(SBC09OUT)/loadUTILS.noi $(SBC09OUT)/UTILS.sym $(SBC09OUT)/../../mos/beeb6809-mos/mosrom.sym >$(SBC09OUT)/loadUTILSandsyms.noi
		echo -e "WAITFORSTOP 1\nR PC mos_handle_res\n" >>$(SBC09OUT)/loadUTILSandsyms.noi


$(BEEBOUT)/UTILS.bin: $(DEPS_B)
$(SBC09OUT)/UTILS.bin: $(DEPS_S)
