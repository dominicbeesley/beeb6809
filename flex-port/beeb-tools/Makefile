ASFLAGS=-3 -v
TARGETS=
TARGETS_TOOLS=	NEWDSSD.bin DUPDSSD.bin
TARGETS_BEEB= $(TARGETS_TOOLS) NEWDSSD.noi DUPDSSD.noi flextools.ssd



include		../../Makefile.defs


DEPS=../../includes/hardware.inc ../../includes/common.inc ../../includes/mosrom.inc ../../includes/noice.inc 


$(BEEBOUT)/NEWDSSD.bin:	$(wildcard ../drivers/wd177x/*.asm) $(wildcard ../drivers/wd177x/*.inc)
$(BEEBOUT)/DUPDSSD.bin:	$(wildcard ../drivers/wd177x/*.asm) $(wildcard ../drivers/wd177x/*.inc)


$(BEEBOUT)/flextools.ssd: ssd/include.lst $(addprefix $(BEEBOUT)/, $(TARGETS_TOOLS))
	../../scripts/buildssd.sh --dest $(BEEBOUT)/flextools.ssd --hostfs ~/hostfs --name flextools ./ssd

$(BEEBOUT)/%.noi:	$(BEEBOUT)/%.bin
	# assume all utils in this directory to run from 1900
	# symbols
	echo "L $(shell $(WINPATH) "$<") 1900 B" >$@
	cat $(basename $<).sym >>$@
	echo "REG PC 1900" >> $@


