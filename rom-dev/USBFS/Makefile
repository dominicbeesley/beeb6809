ASFLAGS=-v -3 
TARGETS=USBFS.bin \
		loadUSBFSandsyms.noi \
		loadUSBFS.noi

DEPS=	$(MOSDIR)/includes/hardware.inc \
	$(MOSDIR)/includes/common.inc \
	$(MOSDIR)/includes/mosrom.inc \
	$(MOSDIR)/includes/noice.inc \
	$(MOSDIR)/includes/oslib.inc \
	$(CHIPKITOUT)/../../mos/beeb6809-mos/mosrom-noice.sym \
	./vinc.inc \
	./vinc.asm \
	Makefile


ROMNO=3

include		../../Makefile.defs


$(CHIPKITOUT)/loadUSBFSandsyms.noi $(CHIPKITOUT)/loadUSBFS.noi: $(CHIPKITOUT)/USBFS.sym
		../../scripts/prefixromsadds.sh $(CHIPKITOUT)/USBFS.sym $(ROMNO)
		./makeloadnoi.sh $(CHIPKITOUT)/USBFS.bin $(CHIPKITOUT)/loadUSBFS.noi $(ROMNO)
		cat $(CHIPKITOUT)/loadUSBFS.noi $(CHIPKITOUT)/USBFS.sym $(CHIPKITOUT)/../../mos/beeb6809-mos/mosrom-noice.sym >$(CHIPKITOUT)/loadUSBFSandsyms.noi
		echo -e "WAITFORSTOP 1\nR PC mos_handle_res\n" >>$(CHIPKITOUT)/loadUSBFSandsyms.noi

$(BEEBOUT)/loadUSBFSandsyms.noi $(BEEBOUT)/loadUSBFS.noi: $(BEEBOUT)/USBFS.sym
		../../scripts/prefixromsadds.sh $(BEEBOUT)/USBFS.sym $(ROMNO)
		./makeloadnoi.sh $(BEEBOUT)/USBFS.bin $(BEEBOUT)/loadUSBFS.noi $(ROMNO)
		cat $(BEEBOUT)/loadUSBFS.noi $(BEEBOUT)/USBFS.sym $(BEEBOUT)/../../mos/beeb6809-mos/mosrom-noice.sym >$(BEEBOUT)/loadUSBFSandsyms.noi
		echo -e "WAITFORSTOP 1\nR PC mos_handle_res\n" >>$(BEEBOUT)/loadUSBFSandsyms.noi

