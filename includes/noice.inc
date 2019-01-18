
	IF NOICE_CODE_BASE
	ELSE
NOICE_CODE_BASE		EQU	$F100	; a hole to be left here for the noice debugger
					; if this constant is changed remember to update
					; README.txt, MONXXXX-dom1.asm and mosloader.asm
					; as required
	ENDIF

	IF NOICE_CODE_LEN
	ELSE
NOICE_CODE_LEN		EQU	$03A0	; TODO: get this from the NOICE code?
	ENDIF

;; - this now must be defined when building
;;NOICE_RAM_START		EQU     $A00	; START OF MONITOR RAM Workspace - use A00 for 
;;					; now which is Serial transient command buffer, 
;;					; might need to make an "official" hole in the 
;;					; memory map

NOICE_BAUD_RATE		EQU	115200	; Baud rate for serial comms

