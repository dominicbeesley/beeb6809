AS=asm6809
ASFLAGS=-3 -v
TARGETS=		testrom.bin

DEPS=../../includes/hardware.inc ../../includes/common.inc ../../includes/mosrom.inc 

all:	$(TARGETS)


testrom.bin:		testrom.asm $(DEPS)
			$(AS) $(ASFLAGS) -o $@ -l $(basename $@).lst $<



clean:
		-rm *.bin
		-rm *.lst
		-rm *.sym
