********************************************************************************
* BEEB DRIVER
********************************************************************************

* This version of the drivers has no ORGs so that it can be included in a tool
* and the drivers are placed at the current PC, use drivers-flex.asm to have
* the drivers placed with ORGS


DRIVERS_FLEX	EQU	0				; don't include FLEX specific stuff i.e. printer spooling tests



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


