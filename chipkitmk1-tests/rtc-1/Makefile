TARGETS_CHIPKIT=	rtc-1.hex rtc-1.noi
include		../../Makefile.defs

ASFLAGS=-3 -v

$(CHIPKITOUT)/rtc-1.noi:	$(CHIPKITOUT)/rtc-1.hex
		$(MAKELOADNOI) $(basename $<) 2000

