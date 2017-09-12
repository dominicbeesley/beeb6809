AS=asm6809 -v -3 

DEPS=../../includes/hardware.inc ../../includes/common.inc ../../includes/mosrom.inc ../../includes/noice.inc 


all:			mosrom.bin mosrom-noice.bin

mosrom.bin:		mosrom.asm $(DEPS)
			$(AS) --define NOICE=0 -o $@ -l $(basename $@).lst $<

mosloadandrun.noi:
			./makeloadnoi.sh

mosrom-noice.bin:	mosrom.asm $(DEPS) ../noice/noice_beeb6309/noice6309-ovr.bin mosloadandrun.noi
			$(AS) --define NOICE=1 -o $@ -l $(basename $@).lst $<
			perl ../../scripts/getsymbols.pl <$(basename $@).lst >$(basename $@).sym

			
			
			cat mosloadandrun.noi $(basename $@).sym >mosloadandsyms.noi
			cat mosloadandrun.noi $(basename $@).sym >mosloadandsymsrun.noi

			echo "WAITFORSTOP" >>mosloadandsymsrun.noi
			echo "GO mos_handle_res" >>mosloadandsymsrun.noi


clean:
		-rm *.bin
		-rm *.lst
		-rm *.sym
		-rm mosloadandsyms.noi
		-rm mosloadandsymsrun.noi