TARGETS_CHIPKIT=	adc-1.hex adc-1.noi
include		../../Makefile.defs

ASFLAGS=-3 -v

$(CHIPKITOUT)/adc-1.noi:	$(CHIPKITOUT)/adc-1.hex
		$(MAKELOADNOI) $(basename $<) 2000

