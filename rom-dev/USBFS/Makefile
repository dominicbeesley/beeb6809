ASFLAGS=-v -3 
TARGETS=	USBFS.bin \
		loadUSBFSandsyms.noi \
		loadUSBFS.noi

DEPS=	../../includes/hardware.inc \
	../../includes/common.inc \
	../../includes/mosrom.inc \
	../../includes/noice.inc \
	../../includes/oslib.inc \
	./vinc.inc \
	./vinc.asm \
	Makefile


#	$(CHIPKITOUT)/../../mos/beeb6809-mos/mosrom-noice.sym \


ROMNO=2

include		../../Makefile.defs


$(CHIPKITOUT)/loadUSBFSandsyms.noi $(CHIPKITOUT)/loadUSBFS.noi: $(CHIPKITOUT)/USBFS.sym
		../../scripts/prefixromsadds.sh $(CHIPKITOUT)/USBFS.sym $(ROMNO)
		./makeloadnoi.sh $(CHIPKITOUT)/USBFS.bin $(CHIPKITOUT)/loadUSBFS.noi $(ROMNO)
		cat $(CHIPKITOUT)/loadUSBFS.noi $(CHIPKITOUT)/USBFS.sym $(CHIPKITOUT)/../../mos/beeb6809-mos/mosrom.sym >$(CHIPKITOUT)/loadUSBFSandsyms.noi
		echo -e "WAITFORSTOP 1\nR PC mos_handle_res\n" >>$(CHIPKITOUT)/loadUSBFSandsyms.noi

$(BEEBOUT)/loadUSBFSandsyms.noi $(BEEBOUT)/loadUSBFS.noi: $(BEEBOUT)/USBFS.sym
		../../scripts/prefixromsadds.sh $(BEEBOUT)/USBFS.sym $(ROMNO)
		./makeloadnoi.sh $(BEEBOUT)/USBFS.bin $(BEEBOUT)/loadUSBFS.noi $(ROMNO)
		cat $(BEEBOUT)/loadUSBFS.noi $(BEEBOUT)/USBFS.sym $(BEEBOUT)/../../mos/beeb6809-mos/mosrom.sym >$(BEEBOUT)/loadUSBFSandsyms.noi
		echo -e "WAITFORSTOP 1\nR PC mos_handle_res\n" >>$(BEEBOUT)/loadUSBFSandsyms.noi

