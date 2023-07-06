TARGETS_CHIPKIT=	vinc-1.hex vinc-1.noi
include		../../Makefile.defs

ASFLAGS=-3 -v

$(CHIPKITOUT)/vinc-1.noi:	$(CHIPKITOUT)/vinc-1.hex
		$(MAKELOADNOI) $(basename $<) 2000

