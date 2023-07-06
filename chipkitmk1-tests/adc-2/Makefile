TARGETS_CHIPKIT=	adc-2.hex adc-2.noi
include		../../Makefile.defs

ASFLAGS=-3 -v

$(CHIPKITOUT)/adc-2.noi:	$(CHIPKITOUT)/adc-2.hex
		$(MAKELOADNOI) $(basename $<) 2000

