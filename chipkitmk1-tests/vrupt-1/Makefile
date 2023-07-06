TARGETS_CHIPKIT=	vrupt-1.hex vrupt-1.noi
include		../../Makefile.defs

ASFLAGS=-3 -v

$(CHIPKITOUT)/vrupt-1.noi:	$(CHIPKITOUT)/vrupt-1.hex
		$(MAKELOADNOI) $(basename $<) 2000

