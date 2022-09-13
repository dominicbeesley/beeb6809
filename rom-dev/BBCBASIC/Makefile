AS=asm6809 -v -9

TARGETS=		6809BAS.bin \
			6809BAS-6502ass.bin \
			loadbasicandsyms.noi \
			loadbasic6309andsyms.noi \
			6309BAS.bin

TARGETS_BEEB=		TESTASM.ssd \
			TESTAS63.ssd


#			6809BAS-6309ass.bin \


TARGETS_FLEX= 		FLEXBAS.BIN \
			FLEXBBC.BIN

TARGETS_SBC09=			SBC6809BAS_68681.BIN \
			SBC6309EBAS_68681.BIN \
			SBC6309NBAS_68681.BIN \
			SBC6809BAS.BIN \
			SBC6309EBAS.BIN \
			SBC6309NBAS.BIN

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



$(BEEBOUT)/test-asm-xroar-%.asm:asm-test-%.txt mkasmtest.pl
	perl mkasmtest.pl -A $< $@

$(BEEBOUT)/test-asm-xroar-63-%.asm:asm-test-%.txt mkasmtest.pl
	perl mkasmtest.pl -3 -A $< $@


$(BEEBOUT)/test-asm-xroar-%.bin:$(BEEBOUT)/test-asm-xroar-%.asm
	$(AS) $(ASFLAGS) -o $@ -l $(basename $@).lst $<

$(BEEBOUT)/test-asm-xroar-63-%.bin:$(BEEBOUT)/test-asm-xroar-63-%.asm
	$(AS) $(ASFLAGS) -3 -o $@ -l $(basename $@).lst $<


$(BEEBOUT)/test-asm-beeb-1.bbc: SAVE=C.BBC681
$(BEEBOUT)/test-asm-beeb-1.bbc: CHAIN=B.ASM682
$(BEEBOUT)/test-asm-beeb-2.bbc: SAVE=C.BBC682
$(BEEBOUT)/test-asm-beeb-2.bbc: CHAIN=B.ASM683
$(BEEBOUT)/test-asm-beeb-3.bbc: SAVE=C.BBC683
$(BEEBOUT)/test-asm-beeb-3.bbc: CHAIN=B.ASM684
$(BEEBOUT)/test-asm-beeb-4.bbc: SAVE=C.BBC684

$(BEEBOUT)/test-asm-beeb-63-1.bbc: SAVE=C.BBC631
$(BEEBOUT)/test-asm-beeb-63-1.bbc: CHAIN=B.ASM632
$(BEEBOUT)/test-asm-beeb-63-2.bbc: SAVE=C.BBC632
$(BEEBOUT)/test-asm-beeb-63-2.bbc: CHAIN=B.ASM633
$(BEEBOUT)/test-asm-beeb-63-3.bbc: SAVE=C.BBC633
$(BEEBOUT)/test-asm-beeb-63-3.bbc: CHAIN=B.ASM634
$(BEEBOUT)/test-asm-beeb-63-4.bbc: SAVE=C.BBC634
$(BEEBOUT)/test-asm-beeb-63-4.bbc: CHAIN=B.ASM635
$(BEEBOUT)/test-asm-beeb-63-5.bbc: SAVE=C.BBC635
$(BEEBOUT)/test-asm-beeb-63-5.bbc: CHAIN=B.ASM636
$(BEEBOUT)/test-asm-beeb-63-6.bbc: SAVE=C.BBC636
$(BEEBOUT)/test-asm-beeb-63-6.bbc: CHAIN=B.ASM637
$(BEEBOUT)/test-asm-beeb-63-7.bbc: SAVE=C.BBC637
$(BEEBOUT)/test-asm-beeb-63-7.bbc: CHAIN=B.ASM638
$(BEEBOUT)/test-asm-beeb-63-8.bbc: SAVE=C.BBC638
$(BEEBOUT)/test-asm-beeb-63-8.bbc: CHAIN=B.ASM639
$(BEEBOUT)/test-asm-beeb-63-9.bbc: SAVE=C.BBC639

$(BEEBOUT)/test-asm-beeb-%.bbc:asm-test-%.txt mkasmtest.pl
	perl mkasmtest.pl -S "$(SAVE)" -C "$(CHAIN)" -B $< $@


$(BEEBOUT)/test-asm-beeb-63-%.bbc:asm-test-%.txt mkasmtest.pl
	perl mkasmtest.pl -3 -S "$(SAVE)" -C "$(CHAIN)" -B $< $@


$(BEEBOUT)/test-asm-beeb-%.ffb:$(BEEBOUT)/test-asm-beeb-%.bbc
	basictool -t $< $@


XROARASMTEST=$(BEEBOUT)/test-asm-xroar-1.bin $(BEEBOUT)/test-asm-xroar-2.bin $(BEEBOUT)/test-asm-xroar-3.bin  $(BEEBOUT)/test-asm-xroar-4.bin
BBCASMTEST=$(BEEBOUT)/test-asm-beeb-1.ffb $(BEEBOUT)/test-asm-beeb-2.ffb $(BEEBOUT)/test-asm-beeb-3.ffb $(BEEBOUT)/test-asm-beeb-4.ffb

XROARASMTEST63=$(BEEBOUT)/test-asm-xroar-63-1.bin $(BEEBOUT)/test-asm-xroar-63-2.bin $(BEEBOUT)/test-asm-xroar-63-3.bin $(BEEBOUT)/test-asm-xroar-63-4.bin $(BEEBOUT)/test-asm-xroar-63-5.bin  $(BEEBOUT)/test-asm-xroar-63-6.bin $(BEEBOUT)/test-asm-xroar-63-7.bin $(BEEBOUT)/test-asm-xroar-63-8.bin $(BEEBOUT)/test-asm-xroar-63-9.bin
BBCASMTEST63=$(BEEBOUT)/test-asm-beeb-63-1.ffb $(BEEBOUT)/test-asm-beeb-63-2.ffb $(BEEBOUT)/test-asm-beeb-63-3.ffb $(BEEBOUT)/test-asm-beeb-63-4.ffb $(BEEBOUT)/test-asm-beeb-63-5.ffb $(BEEBOUT)/test-asm-beeb-63-6.ffb $(BEEBOUT)/test-asm-beeb-63-7.ffb $(BEEBOUT)/test-asm-beeb-63-8.ffb $(BEEBOUT)/test-asm-beeb-63-9.ffb


.PRECIOUS: $(addsuffix .asm, $(basename $(XROARASMTEST63) $(XROARASMTEST)))

$(BEEBOUT)/TESTASM.ssd: $(BBCASMTEST) $(XROARASMTEST)
	dfs form -80 $@
	dfs title $@ "TESTASM6809"
	dfs opt4 -3 $@
	dfs add -f "C.XRR681" $@ $(BEEBOUT)/test-asm-xroar-1.bin
	dfs add -f "C.XRR682" $@ $(BEEBOUT)/test-asm-xroar-2.bin
	dfs add -f "C.XRR683" $@ $(BEEBOUT)/test-asm-xroar-3.bin
	dfs add -f "C.XRR684" $@ $(BEEBOUT)/test-asm-xroar-4.bin
	dfs add -f "B.ASM681" $@ $(BEEBOUT)/test-asm-beeb-1.ffb
	dfs add -f "B.ASM682" $@ $(BEEBOUT)/test-asm-beeb-2.ffb
	dfs add -f "B.ASM683" $@ $(BEEBOUT)/test-asm-beeb-3.ffb
	dfs add -f "B.ASM684" $@ $(BEEBOUT)/test-asm-beeb-4.ffb

$(BEEBOUT)/TESTAS63.ssd: $(BBCASMTEST63) $(XROARASMTEST63)
	dfs form -80 $@
	dfs title $@ "TESTASM6309"
	dfs opt4 -3 $@
	dfs add -f "C.XRR631" $@ $(BEEBOUT)/test-asm-xroar-63-1.bin
	dfs add -f "C.XRR632" $@ $(BEEBOUT)/test-asm-xroar-63-2.bin
	dfs add -f "C.XRR633" $@ $(BEEBOUT)/test-asm-xroar-63-3.bin
	dfs add -f "C.XRR634" $@ $(BEEBOUT)/test-asm-xroar-63-4.bin
	dfs add -f "C.XRR635" $@ $(BEEBOUT)/test-asm-xroar-63-5.bin
	dfs add -f "C.XRR636" $@ $(BEEBOUT)/test-asm-xroar-63-6.bin
	dfs add -f "C.XRR637" $@ $(BEEBOUT)/test-asm-xroar-63-7.bin
	dfs add -f "C.XRR638" $@ $(BEEBOUT)/test-asm-xroar-63-8.bin
	dfs add -f "C.XRR639" $@ $(BEEBOUT)/test-asm-xroar-63-9.bin
	dfs add -f "B.ASM631" $@ $(BEEBOUT)/test-asm-beeb-63-1.ffb
	dfs add -f "B.ASM632" $@ $(BEEBOUT)/test-asm-beeb-63-2.ffb
	dfs add -f "B.ASM633" $@ $(BEEBOUT)/test-asm-beeb-63-3.ffb
	dfs add -f "B.ASM634" $@ $(BEEBOUT)/test-asm-beeb-63-4.ffb
	dfs add -f "B.ASM635" $@ $(BEEBOUT)/test-asm-beeb-63-5.ffb
	dfs add -f "B.ASM636" $@ $(BEEBOUT)/test-asm-beeb-63-6.ffb
	dfs add -f "B.ASM637" $@ $(BEEBOUT)/test-asm-beeb-63-7.ffb
	dfs add -f "B.ASM638" $@ $(BEEBOUT)/test-asm-beeb-63-8.ffb
	dfs add -f "B.ASM639" $@ $(BEEBOUT)/test-asm-beeb-63-9.ffb


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
		$(AS) $(ASFLAGS) --define ASSEMBLER_6809 --define CPU_6809 --define MACH_BEEB=1 -o $@ -l $(basename $@).lst $<
		perl $(SCRIPTS)/getsymbols.pl <$(basename $@).lst >$(basename $@).sym

		echo $$(( 0x$$(sed -n -e 's/DEF *__FREESPACE *\(.*\)/\1/p' <$(basename $@).sym) )) $$(date) >> $(notdir $(basename $@))_free.txt

$(CHIPKITOUT)/6809BAS.bin: 6809BAS.asm $(DEPS)
		$(AS) $(ASFLAGS) --define ASSEMBLER_6809 --define CPU_6809 --define MACH_CHIPKIT=1 -o $@ -l $(basename $@).lst $<
		perl $(SCRIPTS)/getsymbols.pl <$(basename $@).lst >$(basename $@).sym




$(BEEBOUT)/6809BAS-6502ass.bin: 6809BAS-6502ass.asm $(DEPS)
		$(AS) $(ASFLAGS) --define ASSEMBLER_6809 --define CPU_6809 --define MACH_BEEB=1 -o $@ -l $(basename $@).lst $<
		perl $(SCRIPTS)/getsymbols.pl <$(basename $@).lst >$(basename $@).sym

		echo $$(( 0x$$(sed -n -e 's/DEF *__FREESPACE *\(.*\)/\1/p' <$(basename $@).sym) )) $$(date) >> $(notdir $(basename $@))_free.txt

$(CHIPKITOUT)/6809BAS-6502ass.bin: 6809BAS-6502ass.asm $(DEPS)
		$(AS) $(ASFLAGS) --define ASSEMBLER_6809 --define CPU_6809 --define MACH_CHIPKIT=1 -o $@ -l $(basename $@).lst $<
		perl $(SCRIPTS)/getsymbols.pl <$(basename $@).lst >$(basename $@).sym


$(MATCHBOXOUT)/6809BAS-6502ass.bin: 6809BAS-6502ass.asm $(DEPS)
		$(AS) $(ASFLAGS) --define ASSEMBLER_6809 --define CPU_6809 --define MACH_MATCHBOX=1 -o $@ -l $(basename $@).lst $<
		perl $(SCRIPTS)/getsymbols.pl <$(basename $@).lst >$(basename $@).sym


$(MATCHBOXOUT)/6809BAS.bin: 6809BAS.asm $(DEPS)
		$(AS) $(ASFLAGS) --define ASSEMBLER_6809 --define CPU_6809 --define MACH_MATCHBOX=1 -o $@ -l $(basename $@).lst $<
		perl $(SCRIPTS)/getsymbols.pl <$(basename $@).lst >$(basename $@).sym




$(FLEXOUT)/FLEXBAS.BIN:	6809BAS.asm $(DEPS)
		$(AS) -S --define FLEX=1 -o $(basename $@).hex -l $(basename $@).lst $<
		perl $(BASEDIR)/scripts/flex/hex2bin.pl $(basename $@).hex $@
$(FLEXOUT)/FLEXBBC.BIN:	6809BAS.asm $(DEPS)
		$(AS) -S --define FLEX=1 --define FLEXBBC=1 -o $(basename $@).hex -l $(basename $@).lst $<
		perl $(BASEDIR)/scripts/flex/hex2bin.pl $(basename $@).hex $@

$(SBC09OUT)/SBC6809BAS.BIN:	6809BAS.asm SBC09_MOS.asm $(DEPS)
		echo "SBC09VERSION EQU /`git rev-parse --short HEAD`/" > SBC09VERSION.inc
		$(AS) $(ASFLAGS) --define SBC09=1 --define BASEADDR=0xC000 --define ASSEMBLER_6809 --define CPU_6809 -o $@ -l $(basename $@).lst $< SBC09_MOS.asm
		rm -f SBC09VERSION.inc

$(SBC09OUT)/SBC6309EBAS.BIN:	6809BAS.asm SBC09_MOS.asm $(DEPS)
		echo "SBC09VERSION EQU /`git rev-parse --short HEAD`/" > SBC09VERSION.inc
		$(AS) $(ASFLAGS) -3 --define SBC09=1 --define BASEADDR=0xC000 --define ASSEMBLER_6809 --define CPU_6309 -o $@ -l $(basename $@).lst $< SBC09_MOS.asm
		rm -f SBC09VERSION.inc

$(SBC09OUT)/SBC6309NBAS.BIN:	6809BAS.asm SBC09_MOS.asm $(DEPS)
		echo "SBC09VERSION EQU /`git rev-parse --short HEAD`/" > SBC09VERSION.inc
		$(AS) $(ASFLAGS) -3 --define SBC09=1 --define BASEADDR=0xC000 --define ASSEMBLER_6809 --define CPU_6309 --define NATIVE -o $@ -l $(basename $@).lst $< SBC09_MOS.asm
		rm -f SBC09VERSION.inc

$(SBC09OUT)/SBC6809BAS_68681.BIN:	6809BAS.asm SBC09_MOS_68681.asm $(DEPS)
		echo "SBC09VERSION EQU /`git rev-parse --short HEAD`/" > SBC09VERSION.inc
		$(AS) $(ASFLAGS) --define SBC09=1 --define ASSEMBLER_6809 --define CPU_6809 -o $@ -l $(basename $@).lst $< SBC09_MOS_68681.asm
		rm -f SBC09VERSION.inc

$(SBC09OUT)/SBC6309EBAS_68681.BIN:	6809BAS.asm SBC09_MOS_68681.asm $(DEPS)
		echo "SBC09VERSION EQU /`git rev-parse --short HEAD`/" > SBC09VERSION.inc
		$(AS) $(ASFLAGS) -3 --define SBC09=1 --define ASSEMBLER_6309 --define CPU_6309 -o $@ -l $(basename $@).lst $< SBC09_MOS_68681.asm
		rm -f SBC09VERSION.inc

$(SBC09OUT)/SBC6309NBAS_68681.BIN:	6809BAS.asm SBC09_MOS_68681.asm $(DEPS)
		echo "SBC09VERSION EQU /`git rev-parse --short HEAD`/" > SBC09VERSION.inc
		$(AS) $(ASFLAGS) -3 --define SBC09=1 --define ASSEMBLER_6309 --define CPU_6309 --define NATIVE -o $@ -l $(basename $@).lst $< SBC09_MOS_68681.asm
		rm -f SBC09VERSION.inc

$(BEEBOUT)/6809BAS.bin: $(DEPS)
$(BEEBOUT)/6809BAS-6309ass.bin: $(DEPS)
$(BEEBOUT)/6809BAS-6502ass.bin: $(DEPS)
$(CHIPKITOUT)/6809BAS.bin: $(DEPS)
$(CHIPKITOUT)/6809BAS-6309ass.bin: $(DEPS)
$(CHIPKITOUT)/6809BAS-6502ass.bin: $(DEPS)
$(FLEXOUT)/FLEXBAS.bin: $(DEPS)
$(FLEXOUT)/FLEXBBC.bin: $(DEPS)
$(SBC09OUT)/SBC6809BAS.bin: $(DEPS)
$(SBC09OUT)/SBC6309EBAS.bin: $(DEPS)
$(SBC09OUT)/SBC6309NBAS.bin: $(DEPS)
$(SBC09OUT)/SBC6809BAS_68681.bin: $(DEPS)
$(SBC09OUT)/SBC6309EBAS_68681.bin: $(DEPS)
$(SBC09OUT)/SBC6309NBAS_68681.bin: $(DEPS)
$(MATCHBOXOUT)/6809BAS.bin: $(DEPS)
