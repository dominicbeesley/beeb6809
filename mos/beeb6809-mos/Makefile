SHELL=bash
ASFLAGS=-3 -v
TARGETS=
TARGETS_CHIPKIT=	mosrom.bin
TARGETS_BEEB=		mosrom-6809.bin \
			mosrom.bin \
			mosrom-nat.bin \
			hostfs			
TARGETS_SBC09= mosrom-6809.srec \
			mosrom.srec \
			mosrom-nat.srec

HOSTFSDIR := ~/hostfs/beebroms

include		../../Makefile.defs

DEPS=			../../includes/hardware.inc ../../includes/common.inc ../../includes/mosrom.inc extras.noi 
DEPS_MAIN=		irq1_main.asm vdu_chardefs.asm  vdu_main.asm sound_main.asm
DEPS_SBC09=		sbc09_irq1.asm  sbc09_uart.asm  sbc09_vdu_uart.asm  

CLEAN_EXTRA=$(addprefix $(CHIPKITOUT)/,mosloadandrun.noi mosloadandsyms.noi \
	 mosloadandsymsrun.noi) \
	 $(addprefix $(BEEBOUT)/,mosloadandrun.noi mosloadandrun-6809.noi mosloadandrun-nat.noi) 

#mosrom.bin:		mosrom.asm $(DEPS)
#			$(AS) $(ASFLAGS) --define NOICE=0 -o $@ -l $(basename $@).lst $<

.PHONY:	$(BEEBOUT)/hostfs

$(BEEBOUT)/hostfs:
		cp $(BEEBOUT)/mosrom.bin $(HOSTFSDIR)/M.MOS6309
		cp $(BEEBOUT)/mosrom-6809.bin $(HOSTFSDIR)/M.MOS6809
		cp $(BEEBOUT)/mosrom-nat.bin $(HOSTFSDIR)/M.MOS630N

$(CHIPKITOUT)/mosrom.bin:	mosrom.asm $(DEPS) $(DEPS_MAIN)
			./mkversion.sh
			$(AS) $(ASFLAGS) --define MACH_CHIPKIT=1 -o $@ -l $(basename $@).lst $<
			perl ../../scripts/getsymbols.pl <$(basename $@).lst >$(basename $@).sym
						
			./makeloadnoi.sh $(CHIPKITOUT) mosrom.bin >$(CHIPKITOUT)/mosloadandrun.noi
			cat $(basename $@).sym >>$(CHIPKITOUT)/mosloadandrun.noi

			if [ -a ./extras.noi ]; then \
				cat ./extras.noi >>$(CHIPKITOUT)/mosloadandrun.noi; \
			fi

			echo "WAITFORSTOP" >>$(CHIPKITOUT)/mosloadandrun.noi
			echo "GO 2000" >>$(CHIPKITOUT)/mosloadandrun.noi

$(BEEBOUT)/mosrom-6809.bin:	mosrom.asm $(DEPS) $(DEPS_MAIN)
			./mkversion.sh
			$(AS) -v --define CPU_6809=1 --define MACH_BEEB=1 --define BLITTER=1 -o $@ -l $(basename $@).lst $<
			perl ../../scripts/getsymbols.pl <$(basename $@).lst >$(basename $@).sym
						
			./makeloadnoi.sh $(BEEBOUT) mosrom-6809.bin >$(BEEBOUT)/mosloadandrun-6809.noi
			cat $(basename $@).sym >>$(BEEBOUT)/mosloadandrun-6809.noi

			if [ -a ./extras.noi ]; then \
				cat ./extras.noi >>$(BEEBOUT)/mosloadandrun-6809.noi; \
			fi


			echo "WAITFORSTOP" >>$(BEEBOUT)/mosloadandrun-6809.noi
			echo "GO 2000" >>$(BEEBOUT)/mosloadandrun-6809.noi

$(BEEBOUT)/mosrom.bin:	mosrom.asm $(DEPS) $(DEPS_MAIN)
			./mkversion.sh
			$(AS) -v -3 --define CPU_6309=1 --define MACH_BEEB=1 --define BLITTER=1 -o $@ -l $(basename $@).lst $<
			perl ../../scripts/getsymbols.pl <$(basename $@).lst >$(basename $@).sym
						
			./makeloadnoi.sh $(BEEBOUT) mosrom.bin >$(BEEBOUT)/mosloadandrun.noi
			cat $(basename $@).sym >>$(BEEBOUT)/mosloadandrun.noi

			if [ -a ./extras.noi ]; then \
				cat ./extras.noi >>$(BEEBOUT)/mosloadandrun.noi; \
			fi

			echo "WAITFORSTOP" >>$(BEEBOUT)/mosloadandrun.noi
			echo "GO 2000" >>$(BEEBOUT)/mosloadandrun.noi

$(BEEBOUT)/mosrom-nat.bin:	mosrom.asm $(DEPS) $(DEPS_MAIN)
			./mkversion.sh
			$(AS) -v -3 --define NATIVE=1 --define CPU_6309=1 --define MACH_BEEB=1 --define BLITTER=1 -o $@ -l $(basename $@).lst $<
			perl ../../scripts/getsymbols.pl <$(basename $@).lst >$(basename $@).sym
						
			./makeloadnoi.sh $(BEEBOUT) mosrom-nat.bin >$(BEEBOUT)/mosloadandrun-nat.noi
			cat $(basename $@).sym >>$(BEEBOUT)/mosloadandrun-nat.noi

			if [ -a ./extras.noi ]; then \
				cat ./extras.noi >>$(BEEBOUT)/mosloadandrun-nat.noi; \
			fi


			echo "WAITFORSTOP" >>$(BEEBOUT)/mosloadandrun-nat.noi
			echo "GO 2000" >>$(BEEBOUT)/mosloadandrun-nat.noi

$(SBC09OUT)/mosrom-6809.srec:	mosrom.asm $(DEPS) $(DEPS_SBC09)
			./mkversion.sh
			$(AS) -S -v --define CPU_6809=1 --define MACH_SBC09=1 -o $@ -l $(basename $@).lst $<

			srec_cat $@ -fill 0xFF 0xC000 0x10000 -offset -0xC000 -o $(basename $@).bin -binary

			perl ../../scripts/getsymbols.pl <$(basename $@).lst >$(basename $@).sym
						
			./makeloadnoi.sh $(SBC09OUT) mosrom-6809.srec >$(SBC09OUT)/mosloadandrun-6809.noi
			cat $(basename $@).sym >>$(SBC09OUT)/mosloadandrun-6809.noi

			if [ -a ./extras.noi ]; then \
				cat ./extras.noi >>$(SBC09OUT)/mosloadandrun-6809.noi; \
			fi


			echo "WAITFORSTOP" >>$(BEEBOUT)/mosloadandrun-6809.noi
			echo "GO 2000" >>$(BEEBOUT)/mosloadandrun-6809.noi

$(SBC09OUT)/mosrom.srec:	mosrom.asm $(DEPS)	$(DEPS_SBC09)
			./mkversion.sh
			$(AS) -S -v -3 --define CPU_6309=1 --define MACH_SBC09=1 -o $@ -l $(basename $@).lst $<

			srec_cat $@ -fill 0xFF 0xC000 0x10000 -offset -0xC000 -o $(basename $@).bin -binary

			perl ../../scripts/getsymbols.pl <$(basename $@).lst >$(basename $@).sym
						
			./makeloadnoi.sh $(SBC09OUT) mosrom.srec >$(SBC09OUT)/mosloadandrun.noi
			cat $(basename $@).sym >>$(SBC09OUT)/mosloadandrun.noi

			if [ -a ./extras.noi ]; then \
				cat ./extras.noi >>$(SBC09OUT)/mosloadandrun.noi; \
			fi

			echo "WAITFORSTOP" >>$(SBC09OUT)/mosloadandrun.noi
			echo "GO 2000" >>$(SBC09OUT)/mosloadandrun.noi

$(SBC09OUT)/mosrom-nat.srec:	mosrom.asm $(DEPS)	$(DEPS_SBC09)
			./mkversion.sh
			$(AS) -S -v -3 --define NATIVE=1 --define CPU_6309=1 --define MACH_SBC09=1 -o $@ -l $(basename $@).lst $<

			srec_cat $@ -fill 0xFF 0xC000 0x10000 -offset -0xC000 -o $(basename $@).bin -binary

			perl ../../scripts/getsymbols.pl <$(basename $@).lst >$(basename $@).sym
						
			./makeloadnoi.sh $(SBC09OUT) mosrom-nat.srec >$(SBC09OUT)/mosloadandrun-nat.noi
			cat $(basename $@).sym >>$(SBC09OUT)/mosloadandrun-nat.noi

			if [ -a ./extras.noi ]; then \
				cat ./extras.noi >>$(SBC09OUT)/mosloadandrun-nat.noi; \
			fi


			echo "WAITFORSTOP" >>$(SBC09OUT)/mosloadandrun-nat.noi
			echo "GO 2000" >>$(SBC09OUT)/mosloadandrun-nat.noi

#clean:
#		-rm *.bin
#		-rm *.lst
#		-rm *.sym
#		-rm mosloadandsyms.noi
#		-rm mosloadandsymsrun.noi
#		-rm mosloadandrun.noi
