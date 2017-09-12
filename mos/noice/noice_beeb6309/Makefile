AS=asm6809 -v -3 

DEPS=../../../includes/hardware.inc ../../../includes/common.inc ../../../includes/mosrom.inc ../../../includes/noice.inc 

#-sa is the stand alone debugger ROM image
#-ovr is the overlay to be included in the NOICE hole in the MOS rom

all:			noice6309-sa.bin noice6309-ovr.bin

noice6309-sa.bin:	MON6309-dom1.asm $(DEPS)
			$(AS) --define STANDALONE=1 -o $@ -l $(basename $@).lst $<

noice6309-ovr.bin:	MON6309-dom1.asm $(DEPS)
			$(AS) --define STANDALONE=0 -o $@ -l $(basename $@).lst $<


clean:
		-rm *.bin
		-rm *.lst