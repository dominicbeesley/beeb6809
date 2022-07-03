TARGETS_BEEB=	line-1.hex line-1.noi
include		../../../Makefile.defs

ASFLAGS=-v

$(BEEBOUT)/line-1.noi:	$(BEEBOUT)/line-1.hex
		./makeloadnoi.sh "$(BEEBOUT)" line-1 2000

