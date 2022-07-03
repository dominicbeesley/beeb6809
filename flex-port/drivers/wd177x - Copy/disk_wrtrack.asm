	* DB: This taken from the newdisk example, it should be 
	* INCLUDed into the NEWDISK source after the WD177x.inc file
	* this is not included in the "drivers_beeb.asm" or 
	* "drivers_flex.asm" files

	***************************************************************
	* WRITE TRACK ROUTINE *
	***************************************************************
	* THIS SUBROUTINE MUST BE USER SUPPLIED. *
	* IT SIMPLY WRITES THE DATA FOUND AT "WORK" ($0800) TO THE *
	* CURRENT TRACK ON THE DISK. NOTE THAT THE SEEK TO TRACK *
	* OPERATION HAS ALREADY BEEN PERFORMED. IF SINGLE DENSITY, *
	* "TKSZ" BYTES SHOULD BE WRITTEN. IF DOUBLE, "TKSZ*2" *
	* BYTES SHOULD BE WRITTEN. THIS ROUTINE SHOULD PERFORM *
	* ANY NECESSARY DENSITY SELECTION BEFORE WRITING. DOUBLE *
	* DENSITY IS INDICATED BY THE BYTE "DNSITY" BEING NON-ZERO. *
	* THERE ARE NO ENTRY PARAMETERS AND ALL REGISTERS MAY BE *
	* DESTROYED ON EXIT. THE CODE FOR THIS ROUTINE MUST NOT *
	* EXTEND PAST $0800 SINCE THE TRACK DATA IS STORED THERE. *
	**************************************************************


	*********************************************
WRTTRK		LDX	#WORK				; POINT TO DATA
		ORCC	#$50
		LDA	#WTCMD				; SETUP WRITE TRACK COMMAND
		STA	COMREG				; ISSUE COMMAND
		JSR	DEL32U
WRTTR2		LDA	COMREG				; CHECK WD STATUS
		BITA	#$02				; IS WD READY FOR DATA?
		BNE	WRTTR4				; SKIP IF READY
		BITA	#$01				; IS WD BUSY?
		BNE	WRTTR2				; LOOP IF BUSY
		BRA	WRTTR8				; EXIT IF NOT
WRTTR4		LDA	,X+				; GET A DATA BYTE
		STA	DATREG				; SEND TO DISK
		CMPX	#SWKEND				; OUT OF DATA?
		BNE	WRTTR2				; REPEAT IF NOT
		JSR	WAIT1				; LOOP IF SO
		ANDB	#WTMSK
		ANDCC	#$AF
WRTTR8		RTS					;  RETURN