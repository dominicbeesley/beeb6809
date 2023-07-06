TARGETS_BEEB=	modplay09.hex modplay09.bin loadgame.noi 
TARGETS_EXTRA=	hostfs
DEPS=		modload.asm modplay.inc common.inc helptext.mo7.txt
ASFLAGS=-3 -v

HOSTFSDIR=	~/hostfs/mods/

include		../../Makefile.defs

.PHONY:		hostfs

hostfs: 	$(filter %.bin, $(addprefix $(HOSTFSDIR)/, $(TARGETS_BEEB))) $(addsuffix .inf, $(filter %.bin, $(addprefix $(HOSTFSDIR)/, $(TARGETS_BEEB))))

$(HOSTFSDIR)/%.bin: $(BEEBOUT)/%.bin
	cp $< $@

$(HOSTFSDIR)/%.bin.inf: %.bin.inf
	cp $< $@




#$(CHIPKITOUT)/loadgame.noi:	$(CHIPKITOUT)/modplay09.hex modload.rel
#		./makeloadnoi.sh $(CHIPKITOUT)/loadgame.noi
#		cat $(CHIPKITOUT)/loadgame.noi $(CHIPKITOUT)/modplay09.sym > $(CHIPKITOUT)/loadgameandsyms.noi
#		echo "REG PC modplay_debug" >> $(CHIPKITOUT)/loadgameandsyms.noi

$(BEEBOUT)/loadgame.noi:	$(BEEBOUT)/modplay09.bin
		cat "LOAD $(shell $(WINPATH) $(BEEBOUT)/modplay09.hex)" > $(BEEBOUT)/loadgame.noi
		cat $(BEEBOUT)/loadgame.noi $(BEEBOUT)/modplay09.sym > $(BEEBOUT)/loadgameandsyms.noi
		echo "REG PC modplay_debug" >> $(BEEBOUT)/loadgameandsyms.noi
		


#$(BEEBOUT)/modload.rel:	modload.asm
#		$(AS) $(ASFLAGS) --define MACH_BEEB=1 -B -o $@ -l $(basename $@).lst $<