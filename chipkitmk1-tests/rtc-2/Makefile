TARGETS_CHIPKIT=	rtc-2.hex rtc-2.noi
include		../../Makefile.defs

ASFLAGS=-3 -v

$(CHIPKITOUT)/rtc-2.noi:	$(CHIPKITOUT)/rtc-2.hex
		$(MAKELOADNOI) $(basename $<) 2000

