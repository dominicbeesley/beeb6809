	* REST
	*
	* REST RESTORES THE HEAD TO 00
REST		DBUG	'z'
		PSHS	X				; SAVE X REGISTER
		BSR	DRV				; DO SELECT
		ORCC	#$50
		LDA	#RSCMND				; SETUP RESTORE COMMAND
		STA	COMREG				; ISSUE RESTORE COMMAND
		BSR	DEL32U				; DELAY
		LBSR	WAIT				; WAIT TIL WD IS FINISHED
		PULS	X				; RESTORE POINTER
		ANDB	#SEEKMASK			; CHECK FOR ERROR	- DB was D8!
		ANDCC	#$AF
		DBUG_B
		RTS					;  RETURN