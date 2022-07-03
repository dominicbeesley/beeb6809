AS=asm6809 -v -9 

TARGETS=		6809BAS.bin \
			6809BAS-6502ass.bin \
			loadbasicandsyms.noi \
			loadbasic6309andsyms.noi \
			6309BAS.bin


#			6809BAS-6309ass.bin \


TARGETS_FLEX= 		FLEXBAS.BIN \
			FLEXBBC.BIN
TARGETS_MATCHBOX=	6809BAS.bin \
			6809BAS-6502ass.bin \

BASEDIR=../..

DEPS=			$(BASEDIR)/includes/hardware.inc \
			$(BASEDIR)/includes/common.inc \
			$(BASEDIR)/includes/mosrom.inc \
			$(BASEDIR)/includes/noice.inc \
			$(BASEDIR)/includes/oslib.inc \
			macros.inc \
			assembler_share.asm \
			assembler6502.asm \
			assembler6x09.asm \
			parse.inc \
			fp.inc \
			zp.inc \
			tokens.inc \
			layout.inc \
			tokenstable.asm \
			6809-assembler.gen.asm \
			6309-assembler.gen.asm \
			6809BAS.asm			

ROMNO=E
HOSTFSDIR=~/hostfs/beebroms/

include		../../Makefile.defs


.PHONY:	hostfs

hostfs: $(filter %.bin, $(addprefix $(HOSTFSDIR)/, $(TARGETS)))

$(HOSTFSDIR)/%.bin: $(BEEBOUT)/%.bin
	cp $< $@

6809-assembler.gen.asm:	 6x09-ass-readdefs.pl 6x09-assembler.defs.txt
		perl 6x09-ass-readdefs.pl

6309-assembler.gen.asm:	 6x09-ass-readdefs.pl 6x09-assembler.defs.txt
		perl 6x09-ass-readdefs.pl --6309


all: sizelog.txt sizelog6309.txt

sizelog.txt: $(BEEBOUT)/6809BAS.sym
		echo -e "$(shell date +"%F,%T")\t$(shell ./calc-free-space.sh $(BEEBOUT)/6809BAS.sym)" >>sizelog.txt
sizelog6309.txt: $(BEEBOUT)/6809BAS.sym
		echo -e "$(shell date +"%F,%T")\t$(shell ./calc-free-space.sh $(BEEBOUT)/6309BAS.sym)" >>sizelog6309.txt



$(BEEBOUT)/loadbasicandsyms.noi: $(BEEBOUT)/6809BAS.bin
	$(BASEDIR)/scripts/prefixromsadds.sh $(BEEBOUT)/6809BAS.sym $(ROMNO)
	./makeloadnoi.sh $(BEEBOUT)/6809BAS.bin $(BEEBOUT)/loadbasic.noi $(ROMNO)
	cat $(BEEBOUT)/loadbasic.noi $(BEEBOUT)/6809BAS.sym $(BEEBOUT)/../../mos/beeb6809-mos/mosrom.sym >$(BEEBOUT)/loadbasicandsyms.noi
	echo -e "WAITFORSTOP 1\nR PC mos_handle_res\n" >>$(BEEBOUT)/loadbasicandsyms.noi

$(BEEBOUT)/loadbasic6309andsyms.noi: $(BEEBOUT)/6309BAS.bin
	$(BASEDIR)/scripts/prefixromsadds.sh $(BEEBOUT)/6309BAS.sym $(ROMNO)
	./makeloadnoi.sh $(BEEBOUT)/6309BAS.bin $(BEEBOUT)/loadbasic.noi $(ROMNO)
	cat $(BEEBOUT)/loadbasic.noi $(BEEBOUT)/6309BAS.sym $(BEEBOUT)/../../mos/beeb6809-mos/mosrom.sym >$(BEEBOUT)/loadbasic6309andsyms.noi
	echo -e "WAITFORSTOP 1\nR PC mos_handle_res\n" >>$(BEEBOUT)/loadbasic6309andsyms.noi

$(CHIPKITOUT)/loadbasicandsyms.noi: $(CHIPKITOUT)/6809BAS.bin
	$(BASEDIR)/scripts/prefixromsadds.sh $(CHIPKITOUT)/6809BAS.sym $(ROMNO)
	./makeloadnoi.sh $(CHIPKITOUT)/6809BAS.bin $(CHIPKITOUT)/loadbasic.noi $(ROMNO)
	cat $(CHIPKITOUT)/loadbasic.noi $(CHIPKITOUT)/6809BAS.sym $(BEEBOUT)/../../mos/beeb6809-mos/mosrom.sym >$(CHIPKITOUT)/loadbasicandsyms.noi
	echo -e "WAITFORSTOP 1\nR PC mos_handle_res\n" >>$(BEEBOUT)/loadbasicandsyms.noi

$(CHIPKITOUT)/loadbasic6309andsyms.noi: $(CHIPKITOUT)/6309BAS.bin
	$(BASEDIR)/scripts/prefixromsadds.sh $(CHIPKITOUT)/6309BAS.sym $(ROMNO)
	./makeloadnoi.sh $(CHIPKITOUT)/6309BAS.bin $(CHIPKITOUT)/loadbasic.noi $(ROMNO)
	cat $(CHIPKITOUT)/loadbasic.noi $(CHIPKITOUT)/6309BAS.sym $(BEEBOUT)/../../mos/beeb6809-mos/mosrom.sym >$(CHIPKITOUT)/loadbasic6309andsyms.noi
	echo -e "WAITFORSTOP 1\nR PC mos_handle_res\n" >>$(BEEBOUT)/loadbasic6309andsyms.noi

$(BEEBOUT)/6309BAS.bin: 6809BAS.asm $(DEPS)
		$(AS) $(ASFLAGS) -3 --define ASSEMBLER_6309 --define CPU_6309 --define MACH_BEEB=1 -o $@ -l $(basename $@).lst $<
		perl $(SCRIPTS)/getsymbols.pl <$(basename $@).lst >$(basename $@).sym

		echo $$(( 0x$$(sed -n -e 's/DEF *__FREESPACE *\(.*\)/\1/p' <$(basename $@).sym) )) $$(date) >> $(notdir $(basename $@))_free.txt

$(CHIPKITOUT)/6309BAS.bin: 6809BAS.asm $(DEPS)
		$(AS) $(ASFLAGS) -3 --define ASSEMBLER_6309 --define CPU_6309 --define MACH_CHIPKIT=1 -o $@ -l $(basename $@).lst $<
		perl $(SCRIPTS)/getsymbols.pl <$(basename $@).lst >$(basename $@).sym



$(BEEBOUT)/6809BAS.bin: 6809BAS.asm $(DEPS)
		$(AS) $(ASFLAGS) -3 --define ASSEMBLER_6809 --define CPU_6809 --define MACH_BEEB=1 -o $@ -l $(basename $@).lst $<
		perl $(SCRIPTS)/getsymbols.pl <$(basename $@).lst >$(basename $@).sym

		echo $$(( 0x$$(sed -n -e 's/DEF *__FREESPACE *\(.*\)/\1/p' <$(basename $@).sym) )) $$(date) >> $(notdir $(basename $@))_free.txt

$(CHIPKITOUT)/6809BAS.bin: 6809BAS.asm $(DEPS)
		$(AS) $(ASFLAGS) -3 --define ASSEMBLER_6809 --define CPU_6809 --define MACH_CHIPKIT=1 -o $@ -l $(basename $@).lst $<
		perl $(SCRIPTS)/getsymbols.pl <$(basename $@).lst >$(basename $@).sym




$(BEEBOUT)/6809BAS-6502ass.bin: 6809BAS-6502ass.asm $(DEPS)
		$(AS) $(ASFLAGS) -3 --define ASSEMBLER_6809 --define CPU_6809 --define MACH_BEEB=1 -o $@ -l $(basename $@).lst $<
		perl $(SCRIPTS)/getsymbols.pl <$(basename $@).lst >$(basename $@).sym

		echo $$(( 0x$$(sed -n -e 's/DEF *__FREESPACE *\(.*\)/\1/p' <$(basename $@).sym) )) $$(date) >> $(notdir $(basename $@))_free.txt

$(CHIPKITOUT)/6809BAS-6502ass.bin: 6809BAS-6502ass.asm $(DEPS)
		$(AS) $(ASFLAGS) -3 --define ASSEMBLER_6809 --define CPU_6809 --define MACH_CHIPKIT=1 -o $@ -l $(basename $@).lst $<
		perl $(SCRIPTS)/getsymbols.pl <$(basename $@).lst >$(basename $@).sym


$(MATCHBOX)/6809BAS-6502ass.bin: 6809BAS-6502ass.asm $(DEPS)
		$(AS) $(ASFLAGS) -3 --define ASSEMBLER_6809 --define CPU_6809 --define MACH_MATCHBOX=1 -o $@ -l $(basename $@).lst $<
		perl $(SCRIPTS)/getsymbols.pl <$(basename $@).lst >$(basename $@).sym


$(MATCHBOX)/6809BAS.bin: 6809BAS.asm $(DEPS)
		$(AS) $(ASFLAGS) -3 --define ASSEMBLER_6809 --define CPU_6809 --define MACH_MATCHBOX=1 -o $@ -l $(basename $@).lst $<
		perl $(SCRIPTS)/getsymbols.pl <$(basename $@).lst >$(basename $@).sym




$(FLEXOUT)/FLEXBAS.BIN:	6809BAS.asm $(DEPS)
		$(AS) -S --define FLEX=1 -o $(basename $@).hex -l $(basename $@).lst $<
		perl $(BASEDIR)/scripts/flex/hex2bin.pl $(basename $@).hex $@
$(FLEXOUT)/FLEXBBC.BIN:	6809BAS.asm $(DEPS)
		$(AS) -S --define FLEX=1 --define FLEXBBC=1 -o $(basename $@).hex -l $(basename $@).lst $<
		perl $(BASEDIR)/scripts/flex/hex2bin.pl $(basename $@).hex $@


$(BEEBOUT)/6809BAS.bin: $(DEPS)
$(BEEBOUT)/6809BAS-6309ass.bin: $(DEPS)
$(BEEBOUT)/6809BAS-6502ass.bin: $(DEPS)
$(CHIPKITOUT)/6809BAS.bin: $(DEPS)
$(CHIPKITOUT)/6809BAS-6309ass.bin: $(DEPS)
$(CHIPKITOUT)/6809BAS-6502ass.bin: $(DEPS)
$(FLEXOUT)/FLEXBAS.bin: $(DEPS)
$(FLEXOUT)/FLEXBBC.bin: $(DEPS)
$(MATCHBOXOUT)/6809BAS.bin: $(DEPS)


