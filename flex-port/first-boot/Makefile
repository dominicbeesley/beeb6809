ASFLAGS=-v
TARGETS=
TARGETS_FLEX= drv_wd177x.hex drv_mostermio.hex FLEX.SYS.hex boot.noi FLEX.COR.hex



include		../../Makefile.defs


DEPS=../../includes/hardware.inc ../../includes/common.inc ../../includes/mosrom.inc ../../includes/noice.inc 

.DELETE_ON_ERROR:


$(FLEXOUT)/drv_wd177x.hex:	$(wildcard ../drivers/wd177x/*)

$(FLEXOUT)/FLEX.SYS.hex:	FLEX.SYS
	../../scripts/flex/flexbin2hex.pl $< >$@
$(FLEXOUT)/FLEX.COR.hex:	FLEX.COR
	../../scripts/flex/flexbin2hex.pl $< >$@

$(FLEXOUT)/boot.noi: $(FLEXOUT)/FLEX.COR.hex	$(FLEXOUT)/FLEX.SYS.hex	
	echo "L $(shell cygpath -w "$(FLEXOUT)/FLEX.COR.hex")" >$(FLEXOUT)/boot.noi.tmp
#	echo "L $(shell cygpath -w "$(FLEXOUT)/FLEX.SYS.hex")" >$(FLEXOUT)/boot.noi.tmp
	
#	echo "L $(shell cygpath -w "../flex-srcs/getsyms/FLEX.TXT.hex")" >$(FLEXOUT)/boot.noi.tmp
#	echo "L $(shell cygpath -w "../flex-srcs/getsyms/FLEXFMS.TXT.hex")" >>$(FLEXOUT)/boot.noi.tmp
#	echo "L $(shell cygpath -w "../flex-srcs/getsyms/SPOOL.TXT.hex")" >>$(FLEXOUT)/boot.noi.tmp

	echo "L $(shell cygpath -w "$(FLEXOUT)/drv_wd177x.hex")" >>$(FLEXOUT)/boot.noi.tmp
	echo "L $(shell cygpath -w "$(FLEXOUT)/drv_mostermio.hex")" >>$(FLEXOUT)/boot.noi.tmp

	cat $(FLEXOUT)/drv_wd177x.sym >>$(FLEXOUT)/boot.noi.tmp 
	cat $(FLEXOUT)/drv_mostermio.sym >>$(FLEXOUT)/boot.noi.tmp 
	cat ../flex-srcs/getsyms/FLEX.TXT.sym >>$(FLEXOUT)/boot.noi.tmp 
	cat ../flex-srcs/getsyms/FLEXFMS.TXT.sym >>$(FLEXOUT)/boot.noi.tmp 
	cat ../flex-srcs/getsyms/SPOOL.TXT.sym >>$(FLEXOUT)/boot.noi.tmp 
	cat $(dir $(BEEBOUT))/flex-mini-mos/flex-mini-mos-noice.sym >>$(FLEXOUT)/boot.noi.tmp 
	mv $(FLEXOUT)/boot.noi.tmp $(FLEXOUT)/boot.noi


