ASFLAGS=-3 -v
TARGETS=
TARGETS_FLEX= drv_wd177x.hex drv_mostermio.hex FLEX.SYS.hex boot.noi FLEX.COR.hex



include		../../Makefile.defs


DEPS=../../includes/hardware.inc ../../includes/common.inc ../../includes/mosrom.inc ../../includes/noice.inc 


$(FLEXOUT)/FLEX.SYS.hex:	FLEX.SYS
	../../scripts/flex/flexbin2hex.pl <$< >$@
$(FLEXOUT)/FLEX.COR.hex:	FLEX.COR
	../../scripts/flex/flexbin2hex.pl <$< >$@

$(FLEXOUT)/boot.noi: $(FLEXOUT)/FLEX.COR.hex	$(FLEXOUT)/FLEX.SYS.hex	
	echo "L $(shell cygpath -w "$(FLEXOUT)/FLEX.COR.hex")" >$(FLEXOUT)/boot.noi
#	echo "L $(shell cygpath -w "$(FLEXOUT)/FLEX.SYS.hex")" >$(FLEXOUT)/boot.noi
	
#	echo "L $(shell cygpath -w "../flex-srcs/getsyms/FLEX.TXT.hex")" >$(FLEXOUT)/boot.noi
#	echo "L $(shell cygpath -w "../flex-srcs/getsyms/FLEXFMS.TXT.hex")" >>$(FLEXOUT)/boot.noi
#	echo "L $(shell cygpath -w "../flex-srcs/getsyms/SPOOL.TXT.hex")" >>$(FLEXOUT)/boot.noi

	echo "L $(shell cygpath -w "$(FLEXOUT)/drv_wd177x.hex")" >>$(FLEXOUT)/boot.noi
	echo "L $(shell cygpath -w "$(FLEXOUT)/drv_mostermio.hex")" >>$(FLEXOUT)/boot.noi

	cat $(FLEXOUT)/drv_wd177x.sym >>$(FLEXOUT)/boot.noi 
	cat $(FLEXOUT)/drv_mostermio.sym >>$(FLEXOUT)/boot.noi 
	cat ../flex-srcs/getsyms/FLEX.TXT.sym >>$(FLEXOUT)/boot.noi 
	cat ../flex-srcs/getsyms/FLEXFMS.TXT.sym >>$(FLEXOUT)/boot.noi 
	cat ../flex-srcs/getsyms/SPOOL.TXT.sym >>$(FLEXOUT)/boot.noi 
	cat $(BEEBOUT)/../flex-mini-mos/flex-mini-mos-noice.sym >>$(FLEXOUT)/boot.noi 


