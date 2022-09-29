TARGETS_CHIPKIT=	rtc-2.hex rtc-2.noi
include		../../Makefile.defs

ASFLAGS=-3 -v

rtc-2.noi:	rtc-2.hex
		./makeloadnoi.sh rtc-2 2000
		cat rtc-2andsyms.noi > rtc-2andsymsandrun.noi
		echo "GO 2000" >> rtc-2andsymsandrun.noi

