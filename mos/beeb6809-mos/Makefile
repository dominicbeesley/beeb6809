ASFLAGS=-3 -v
TARGETS=mosrom.bin
TARGETS_EXTRA_CHIPKIT=$(CHIPKITOUT)/mosrom-noice.bin
TARGETS_EXTRA_BEEB=	$(BEEBOUT)/mosrom-6809.bin \
					$(BEEBOUT)/mosrom-6809-noice.bin \
					$(BEEBOUT)/mosrom-noice.bin \
					$(BEEBOUT)/mosrom-6809-noice-my.bin \
					$(BEEBOUT)/mosrom-noice-my.bin \
					$(BEEBOUT)/mosrom-noice-nat.bin
include		../../Makefile.defs

DEPS=../../includes/hardware.inc ../../includes/common.inc ../../includes/mosrom.inc ../../includes/noice.inc 

CLEAN_EXTRA=$(addprefix $(CHIPKITOUT)/,mosloadandrun.noi mosloadandsyms.noi \
	 mosloadandsymsrun.noi mosrom-noice.bin mosrom-noice.sym mosrom-noice.lst) \
	 $(addprefix $(BEEBOUT)/,mosloadandrun.noi mosloadandsyms.noi \
	 mosloadandsymsrun.noi mosrom-noice.bin mosrom-noice.sym mosrom-noice.lst)

#mosrom.bin:		mosrom.asm $(DEPS)
#			$(AS) $(ASFLAGS) --define NOICE=0 -o $@ -l $(basename $@).lst $<


$(CHIPKITOUT)/mosloadandrun.noi:
			./makeloadnoi.sh $(CHIPKITOUT) mosrom-noice.bin >$@

$(CHIPKITOUT)/mosrom-noice.bin:	mosrom.asm $(DEPS) ../noice/noice/mon-noice-6309-chipkit-ovr.ovr $(CHIPKITOUT)/mosloadandrun.noi
			./mkversion.sh
			$(AS) $(ASFLAGS) --define NOICE=1 --define MACH_CHIPKIT=1 -o $@ -l $(basename $@).lst $<
			perl ../../scripts/getsymbols.pl <$(basename $@).lst >$(basename $@).sym
						
			cat $(CHIPKITOUT)/mosloadandrun.noi $(basename $@).sym >$(CHIPKITOUT)/mosloadandsyms.noi
			cat $(CHIPKITOUT)/mosloadandrun.noi $(basename $@).sym >$(CHIPKITOUT)/mosloadandsymsrun.noi

			echo "WAITFORSTOP" >>$(CHIPKITOUT)/mosloadandsymsrun.noi
			echo "GO mos_handle_res" >>$(CHIPKITOUT)/mosloadandsymsrun.noi

$(BEEBOUT)/mosrom.bin:	mosrom.asm $(DEPS) 
			./mkversion.sh
			$(AS) -v -3 --define NOICE=0 --define CPU_6809=1 --define MACH_BEEB=1 -o $@ -l $(basename $@).lst $<
			perl ../../scripts/getsymbols.pl <$(basename $@).lst >$(basename $@).sym
$(CHIPKITOUT)/mosrom.bin:	mosrom.asm $(DEPS) 
			./mkversion.sh
			$(AS) -v -3 --define NOICE=0 --define CPU_6809=1 --define MACH_BEEB=1 -o $@ -l $(basename $@).lst $<
			perl ../../scripts/getsymbols.pl <$(basename $@).lst >$(basename $@).sym

$(BEEBOUT)/mosrom-6809.bin:	mosrom.asm $(DEPS) 
			./mkversion.sh
			$(AS) -v --define NOICE=0 --define CPU_6809=1 --define MACH_BEEB=1 -o $@ -l $(basename $@).lst $<
			perl ../../scripts/getsymbols.pl <$(basename $@).lst >$(basename $@).sym



$(BEEBOUT)/mosrom-6809-noice.bin:	mosrom.asm $(DEPS) ../noice/noice/mon-noice-6809-beeb-ovr.ovr 
			./mkversion.sh
			$(AS) -v --define NOICE=1 --define CPU_6809=1 --define MACH_BEEB=1 -o $@ -l $(basename $@).lst $<
			perl ../../scripts/getsymbols.pl <$(basename $@).lst >$(basename $@).sym
						
			./makeloadnoi.sh $(BEEBOUT) mosrom-6809-noice.bin >$(BEEBOUT)/mosloadandrun-6809.noi
			cat $(BEEBOUT)/mosloadandrun-6809.noi $(basename $@).sym >$(BEEBOUT)/mosloadandsyms-6809.noi
			cat $(BEEBOUT)/mosloadandrun-6809.noi $(basename $@).sym >$(BEEBOUT)/mosloadandsymsrun-6809.noi

			echo "WAITFORSTOP" >>$(BEEBOUT)/mosloadandsymsrun-6809.noi
			echo "GO mos_handle_res" >>$(BEEBOUT)/mosloadandsymsrun-6809.noi

$(BEEBOUT)/mosrom-noice.bin:	mosrom.asm $(DEPS) ../noice/noice/mon-noice-6309-beeb-ovr.ovr 
			./mkversion.sh
			$(AS) -v -3 --define NOICE=1 --define CPU_6309=1 --define MACH_BEEB=1 -o $@ -l $(basename $@).lst $<
			perl ../../scripts/getsymbols.pl <$(basename $@).lst >$(basename $@).sym
						
			./makeloadnoi.sh $(BEEBOUT) mosrom-noice.bin >$(BEEBOUT)/mosloadandrun.noi
			cat $(BEEBOUT)/mosloadandrun.noi $(basename $@).sym >$(BEEBOUT)/mosloadandsyms.noi
			cat $(BEEBOUT)/mosloadandrun.noi $(basename $@).sym >$(BEEBOUT)/mosloadandsymsrun.noi

			echo "WAITFORSTOP" >>$(BEEBOUT)/mosloadandsymsrun.noi
			echo "GO mos_handle_res" >>$(BEEBOUT)/mosloadandsymsrun.noi

$(BEEBOUT)/mosrom-noice-nat.bin:	mosrom.asm $(DEPS) ../noice/noice/mon-noice-6309-beeb-ovr.ovr 
			./mkversion.sh
			$(AS) -v -3 --define NATIVE=1 --define NOICE=1 --define CPU_6309=1 --define MACH_BEEB=1 -o $@ -l $(basename $@).lst $<
			perl ../../scripts/getsymbols.pl <$(basename $@).lst >$(basename $@).sym
						
			./makeloadnoi.sh $(BEEBOUT) mosrom-noice-nat.bin >$(BEEBOUT)/mosloadandrun-nat.noi
			cat $(BEEBOUT)/mosloadandrun-nat.noi $(basename $@).sym >$(BEEBOUT)/mosloadandsyms-nat.noi
			cat $(BEEBOUT)/mosloadandrun-nat.noi $(basename $@).sym >$(BEEBOUT)/mosloadandsymsrun-nat.noi

			echo "WAITFORSTOP" >>$(BEEBOUT)/mosloadandsymsrun-nat.noi
			echo "GO mos_handle_res" >>$(BEEBOUT)/mosloadandsymsrun-nat.noi


$(BEEBOUT)/mosrom-6809-noice-my.bin:	mosrom.asm $(DEPS) ../noice/noice/mon-noice-my-6809-beeb-ovr.ovr 
			./mkversion.sh
			$(AS) -v --define NOICE=1 --define NOICE_MY=1 --define CPU_6809=1 --define MACH_BEEB=1 -o $@ -l $(basename $@).lst $<
			perl ../../scripts/getsymbols.pl <$(basename $@).lst >$(basename $@).sym
						
			./makeloadnoi.sh $(BEEBOUT) mosrom-6809-noice-my.bin >$(BEEBOUT)/mosloadandrun-6809-my.noi
			cat $(BEEBOUT)/mosloadandrun-6809-my.noi $(basename $@).sym >$(BEEBOUT)/mosloadandsyms-6809-my.noi
			cat $(BEEBOUT)/mosloadandrun-6809-my.noi $(basename $@).sym >$(BEEBOUT)/mosloadandsymsrun-6809-my.noi

			echo "WAITFORSTOP" >>$(BEEBOUT)/mosloadandsymsrun-6809-my.noi
			echo "GO mos_handle_res" >>$(BEEBOUT)/mosloadandsymsrun-6809-my.noi

$(BEEBOUT)/mosrom-noice-my.bin:	mosrom.asm $(DEPS) ../noice/noice/mon-noice-my-6309-beeb-ovr.ovr 
			./mkversion.sh
			$(AS) -v -3 --define NOICE=1 --define NOICE_MY=1 --define CPU_6309=1 --define MACH_BEEB=1 -o $@ -l $(basename $@).lst $<
			perl ../../scripts/getsymbols.pl <$(basename $@).lst >$(basename $@).sym
						
			./makeloadnoi.sh $(BEEBOUT) mosrom-noice-my.bin >$(BEEBOUT)/mosloadandrun-my.noi
			cat $(BEEBOUT)/mosloadandrun-my.noi $(basename $@).sym >$(BEEBOUT)/mosloadandsyms-my.noi
			cat $(BEEBOUT)/mosloadandrun-my.noi $(basename $@).sym >$(BEEBOUT)/mosloadandsymsrun-my.noi

			echo "WAITFORSTOP" >>$(BEEBOUT)/mosloadandsymsrun-my.noi
			echo "GO mos_handle_res" >>$(BEEBOUT)/mosloadandsymsrun-my.noi


#clean:
#		-rm *.bin
#		-rm *.lst
#		-rm *.sym
#		-rm mosloadandsyms.noi
#		-rm mosloadandsymsrun.noi
#		-rm mosloadandrun.noi