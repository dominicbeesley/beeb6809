TARGETS_CHIPKIT=	vinc-2.hex vinc-2.noi
include		../../Makefile.defs

ASFLAGS=-3 -v

$(CHIPKITOUT)/vinc-2.noi:	$(CHIPKITOUT)/vinc-2.hex
		$(MAKELOADNOI) $(basename $<) 2000

