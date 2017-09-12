AS=asm6809 -v -3 

MOSDIR=../..

DEPS=	$(MOSDIR)/includes/hardware.inc \
	$(MOSDIR)/includes/common.inc \
	$(MOSDIR)/includes/mosrom.inc \
	$(MOSDIR)/includes/noice.inc \
	$(MOSDIR)/includes/oslib.inc \
	../../mos/beeb6809-mos/mosrom-noice.sym \
	./vinc.inc \
	./vinc.asm


all:		USBFS.bin 

USBFS.bin:	USBFS.asm $(DEPS)
		$(AS) -o $@ -l $(basename $@).lst $<
		perl $(MOSDIR)/scripts/getsymbols.pl <$(basename $@).lst >$(basename $@).sym
		./makeloadnoi.sh
		cat loadUSBFS.noi $(basename $@).sym ../../mos/beeb6809-mos/mosrom-noice.sym >loadUSBFSandsyms.noi
		echo -e "WAITFORSTOP 1\nEDIT FE30 0A\nEDIT DF6 80\nR PC mos_handle_res\n" >>loadUSBFSandsyms.noi

clean:
		-rm *.bin
		-rm *.lst
		-rm *.sym
		-rm loadUSBFS.noi
		-rm loadUSBFSandsyms.noi
