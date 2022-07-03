ASFLAGS=-v -3 
TARGETS_BEEB=	HOSTFS.bin \
				loadHOSTFSandsyms.noi \
				loadHOSTFS.noi \
				HOSTFS-myelin.bin \
				loadHOSTFS-myelin-andsyms.noi \
				loadHOSTFS-myelin.noi

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

$(BEEBOUT)/loadHOSTFS-myelin-andsyms.noi $(BEEBOUT)/loadHOSTFS-myelin.noi: $(BEEBOUT)/HOSTFS-myelin.sym
		../../scripts/prefixromsadds.sh $(BEEBOUT)/HOSTFS-myelin.sym $(ROMNO)
		./makeloadnoi.sh $(BEEBOUT)/HOSTFS-myelin.bin $(BEEBOUT)/loadHOSTFS-myelin.noi $(ROMNO)
		cat $(BEEBOUT)/loadHOSTFS-myelin.noi $(BEEBOUT)/HOSTFS-myelin.sym $(BEEBOUT)/../../mos/beeb6809-mos/mosrom.sym >$(BEEBOUT)/loadHOSTFS-myelin-andsyms.noi
		echo -e "WAITFORSTOP 1\nR PC mos_handle_res\n" >>$(BEEBOUT)/loadHOSTFS-myelin-andsyms.noi


$(BEEBOUT)/HOSTFS.bin: $(DEPS)
$(BEEBOUT)/HOSTFS-myelin.bin: $(DEPS)