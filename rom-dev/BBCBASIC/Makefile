AS=asm6809 -v -9 

MOSDIR=../..

DEPS=	$(MOSDIR)/includes/hardware.inc \
	$(MOSDIR)/includes/common.inc \
	$(MOSDIR)/includes/mosrom.inc \
	$(MOSDIR)/includes/noice.inc \
	$(MOSDIR)/includes/oslib.inc \
	macros.inc \
	assembler.inc \
	parse.inc \
	fp.inc \
	zp.inc \
	tokens.inc \
	layout.inc \
	debug_print.asm \
	tokenstable.asm


all:		6809BAS.bin 6809BAS-mb.bin

6809BAS.bin:	6809BAS.asm $(DEPS)
		$(AS) --define MATCHBOX=0 -o $@ -l $(basename $@).lst $<
		perl $(MOSDIR)/scripts/getsymbols.pl <$(basename $@).lst >$(basename $@).sym
		./makeloadnoi.sh
		cat loadbasic.noi $(basename $@).sym >loadbasicandsyms.noi
		cat loadbasic-chipkit.noi $(basename $@).sym >loadbasicandsyms-chipkit.noi

6809BAS-mb.bin:	6809BAS.asm $(DEPS)
		$(AS) --define MATCHBOX=1 -o $@ -l $(basename $@).lst $<

clean:
		-rm *.bin
		-rm *.lst
		-rm *.sym
		-rm loadbasic.noi
		-rm loadbasic-chipkit.noi
		-rm loadbasicandsyms.noi
		-rm loadbasicandsyms-chipkit.noi