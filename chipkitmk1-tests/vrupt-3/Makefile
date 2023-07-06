TARGETS_CHIPKIT=	vrupt-3.hex
include		../../Makefile.defs

ASFLAGS=-3 -v

$(CHIPKITOUT)/vrupt-3.noi:	$(CHIPKITOUT)/vrupt-3.hex
		$(MAKELOADNOI) $(basename $<) 2000
