********************************************************************************
* BEEB DRIVER
********************************************************************************

* This version of the drivers will place itself in the FLEX memory hole defined
* for the disk drivers and set up the flex jump vectors at DE00


DRIVERS_FLEX	EQU	1				; don't include FLEX specific stuff i.e. printer spooling tests

PRCNT		EQU	$CC34

		include	"wd177x.inc"

		ORG	$DE00
DREAD		JMP	READ
DWRITE		JMP	WRITE
DVERFY		JMP	VERIFY
RESTOR		JMP	REST
DRIVE		JMP	DRV
DCHECK		JMP	CHKRDY
DQUICK		JMP	CHKRDY
DINIT		JMP	INIT
DWARM		JMP	WARM
DSEEK		JMP	SEEK


		include "disk_vars.asm"

		include "disk_init.asm"

		include "disk_read_sector.asm"

		include "disk_wait_command.asm"

		include "disk_seek.asm"

		include "disk_write_sector.asm"

		include "disk_verify_sector.asm"

		include "disk_restore.asm"

		include "disk_drive_sel.asm"

		include "disk_check_ready.asm"

		include "disk_delay32.asm"


