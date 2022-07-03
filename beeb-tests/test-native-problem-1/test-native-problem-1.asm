		

		include "../../includes/oslib.inc"
		include "../../includes/common.inc"


		org	$2000


fred_MYELIN_SERIAL_STATUS	EQU	$FCA1
fred_MYELIN_SERIAL_DATA		EQU	$FCA0
MYELIN_SERIAL_TXRDY		EQU	2
MYELIN_SERIAL_RXRDY		EQU	1
MYELIN				EQU	1



main

		ldmd	#1

		; simple read from and write back to the hostfs/myelin port
		LDA	#MYELIN_SERIAL_RXRDY
1		BITA	fred_MYELIN_SERIAL_STATUS
		BEQ	1B
		LDA	fred_MYELIN_SERIAL_DATA
		STA	fred_MYELIN_SERIAL_DATA
		BRA	main