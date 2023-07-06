TARGETS_CHIPKIT=	vrupt-2.hex vrupt-2.noi
include		../../Makefile.defs

ASFLAGS=-3 -v

$(CHIPKITOUT)/vrupt-2.noi:	$(CHIPKITOUT)/vrupt-2.hex
		$(MAKELOADNOI) $(basename $<) 2000

