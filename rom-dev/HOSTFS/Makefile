ASFLAGS=-v -3 

TARGETS_BEEB=	HOSTFS.bin \
		loadHOSTFSandsyms.noi \
		loadHOSTFS.noi \
		HOSTFS-myelin.bin \
		loadHOSTFS-myelin-andsyms.noi \
		loadHOSTFS-myelin.noi

TARGETS_CHIPKIT=HOSTFS-ck.bin \
		loadHOSTFSandsyms.noi \
		loadHOSTFS.noi

TARGETS_SBC09=HOSTFS-sbc09.srec

DEPS=	../../includes/hardware.inc \
		../../includes/common.inc \
		../../includes/mosrom.inc \
		../../includes/noice.inc \
		../../includes/oslib.inc \
		HOSTFS-core.asm \
		VERSION-date.gen.asm \
		Makefile

HOSTFSDIR=~/hostfs/roms69/

ROMNO=C

include		../../Makefile.defs 

.PHONY:		VERSION-date.gen.asm hostfs

hostfs:	$(addprefix $(BEEBOUT)/, $(TARGETS_BEEB))
	cp $(BEEBOUT)/HOSTFS.BIN $(HOSTFSDIR)/R.HOSTFS
	cp $(BEEBOUT)/HOSTFS-myelin.BIN $(HOSTFSDIR)/R.HOSTFSM


VERSION-date.gen.asm: HOSTFS-core.asm HOSTFS.asm
		./gendate.sh		

$(BEEBOUT)/loadHOSTFSandsyms.noi $(BEEBOUT)/loadHOSTFS.noi: $(BEEBOUT)/HOSTFS.sym
		../../scripts/prefixromsadds.sh $(BEEBOUT)/HOSTFS.sym $(ROMNO)
		./makeloadnoi.sh $(BEEBOUT)/HOSTFS.bin $(BEEBOUT)/loadHOSTFS.noi $(ROMNO)
		cat $(BEEBOUT)/loadHOSTFS.noi $(BEEBOUT)/HOSTFS.sym $(BEEBOUT)/../../mos/beeb6809-mos/mosrom.sym >$(BEEBOUT)/loadHOSTFSandsyms.noi
		echo -e "WAITFORSTOP 1\nR PC mos_handle_res\n" >>$(BEEBOUT)/loadHOSTFSandsyms.noi

$(CHIPKITOUT)/loadHOSTFSandsyms.noi $(CHIPKITOUT)/loadHOSTFS.noi: $(CHIPKITOUT)/HOSTFS-ck.sym
		../../scripts/prefixromsadds.sh $(CHIPKITOUT)/HOSTFS-ck.sym $(ROMNO)
		./makeloadnoi.sh $(CHIPKITOUT)/HOSTFS-ck.bin $(CHIPKITOUT)/loadHOSTFS.noi $(ROMNO)
		cat $(CHIPKITOUT)/loadHOSTFS.noi $(CHIPKITOUT)/HOSTFS-ck.sym $(CHIPKITOUT)/../../mos/beeb6809-mos/mosrom.sym >$(CHIPKITOUT)/loadHOSTFSandsyms.noi
		echo -e "WAITFORSTOP 1\nR PC mos_handle_res\n" >>$(CHIPKITOUT)/loadHOSTFSandsyms.noi



$(BEEBOUT)/loadHOSTFS-myelin-andsyms.noi $(BEEBOUT)/loadHOSTFS-myelin.noi: $(BEEBOUT)/HOSTFS-myelin.sym
		../../scripts/prefixromsadds.sh $(BEEBOUT)/HOSTFS-myelin.sym $(ROMNO)
		./makeloadnoi.sh $(BEEBOUT)/HOSTFS-myelin.bin $(BEEBOUT)/loadHOSTFS-myelin.noi $(ROMNO)
		cat $(BEEBOUT)/loadHOSTFS-myelin.noi $(BEEBOUT)/HOSTFS-myelin.sym $(BEEBOUT)/../../mos/beeb6809-mos/mosrom.sym >$(BEEBOUT)/loadHOSTFS-myelin-andsyms.noi
		echo -e "WAITFORSTOP 1\nR PC mos_handle_res\n" >>$(BEEBOUT)/loadHOSTFS-myelin-andsyms.noi

$(BEEBOUT)/HOSTFS.bin: $(DEPS)
$(BEEBOUT)/HOSTFS-myelin.bin: $(DEPS)

$(SBC09OUT)/HOSTFS-sbc09.srec: HOSTFS-sbc09.asm $(DEPS)
		asm6809 -S -9 -d MACH_SBC09=1 -o $@ HOSTFS-sbc09.asm

		srec_cat $@ -fill 0xFF 0x8000 0xC000 -offset -0x8000 -o $(basename $@).bin -binary
