; > HeaderROM
; -----------
; ROM header for non-6502 language ROMs to claim *BASIC command if CoPro matches
; target CPU, disables self if CoPro doesn't match target CPU.
;
; TO DO: On 6809Beeb, service entry won't run as it is 6502 code. CHECK does 6809Beeb
; check validity of service entry? If 6809MOS skips ROMs with entry<>6809 "JMP"
; then service code will be ignored and ROM will work.
;
;
; 18-Jan-2001 v0.01 Service code matches *help and *command with ROM title.
;                   *Help prints ROM title and whole version string.
; 15-Aug-2005 v0.02 *Help prints ROM title and version number only.
; 28-Nov-2008 v0.03 *Help optimised slightly.
; 15-Aug-2015 v0.04 Simple non-matched *Help, claims *BASIC command.
; 03-Oct-2015 v0.05 Watches for Tube being set up to disable other ROMs if
;                   not for this CPU and claim *BASIC, checks for Master
;                   giving 'Not a language' on Reset.
; 17-Oct-2015 v0.06 Checks the CPU on the other side of the Tube.


TUBECPU		EQU	$03	; $03 = ROM type for CPU
TUBEMATCH	EQU 	$7E	; $7E = JMP opcode for CPU


HeaderStart
	JMP	HeaderEnter		; Allows entry at first byte
	IF MACH_MATCHBOX
	FCB	$4C			; 6502 JMP for service entry
	FCB	HeaderService % 256	; 6502 service address - little endian
	FCB	HeaderService / 256	; 6502 service address
	FCB	$E0+TUBECPU		; Service+Language+Tube+CPU
	ELSE
	FCB	0,0,0
	FCB	$60+TUBECPU		; Lang+6809 BASIC		; TODO: check beeb6809 service call handler, make it check for valid 6x09 JMP instruction?
	ENDIF
	FCB	HeaderCopyright-HeaderStart
	FCB	4			; For BASIC, must match which 6502 equivalant to
					; 0: no offset assembly, no OSCLI
					; 2: offset assembly, OSCLI, OPENIN/OUT/UP
					; 4: TIME$
	IF CPU_6309
	FCB	"6309"
	ELSE
	FCB	"6809"
	ENDIF
	FCB	" BASIC",0			; ROM title, for BASIC must be <CPU><SPC>"BASIC"
	FCB	((VERSION / 256) & 15)+'0'	; Version string
	FCB	"."
	FCB	((VERSION / 16) & 15)+'0'
	FCB	(VERSION & 15)+'0'
HeaderCopyright
	FCB	0,"(C)2022 Dossy",0		; Copyright message
	FCB	LOADADDR % 256			; Second processor transfer address
	FCB	LOADADDR / 256			; Note stored in little-endian byte order!
	FCB	0				; 32-bit address
	FCB	0

	;
HeaderService
	FCB 	$48,$C9,$01,$F0,$31,$C9,$11,$F0,$5E,$C9,$27,$F0,$5A,$C9,$06,$F0
	FCB 	$36,$C9,$09,$D0,$30,$B1,$F2,$C9,$0D,$D0,$2A,$20,$E7,$FF,$A2,$00
	FCB 	$BD,$09,$80,$D0,$02,$A9,$20,$C9,$28,$F0,$06,$20,$EE,$FF,$E8,$D0
	FCB 	$EF,$20,$E7,$FF,$68,$60,$AD,$7A,$02,$30,$0A,$A6,$F4,$BD,$A1,$02
	FCB 	$29,$BF,$9D,$A1,$02,$68,$60,$A6,$F0,$BD,$02,$01,$4A,$B0,$F6,$A0
	FCB 	$00,$B1,$FD,$D0,$F0,$71,$FD,$C8,$C0,$17,$D0,$F9,$C9,$EA,$D0,$E5
	FCB 	$A6,$F4,$A9,$8E,$4C,$F4,$FF,$AD,$03,$02,$D0,$D9,$98,$48,$A9,$FF
	FCB 	$20,$06,$04,$90,$F9,$A9,$00,$48,$48,$A9,$F8,$48,$BA,$A0,$01,$A9
	FCB 	$00,$48,$20,$06,$04,$68,$68,$68,$68,$A2,$07,$CA,$D0,$FD,$AE,$E5
	FCB 	$FE,$A9,$BF,$20,$06,$04,$68,$A8,$E0,TUBEMATCH,$D0,$9F,$A2,$0F
	FCB 	$BD,$A1,$02,$29,$4F,$C9,$40+TUBECPU,$F0,$08,$BD,$A1,$02,$29,$BF
	FCB 	$9D,$A1,$02,$CA,$10,$EC,$AE,$8C,$02,$30,$09,$BD,$A1,$02,$29,$4F
	FCB 	$C9,$47,$F0,$05,$A6,$F4,$8E,$8C,$02,$A6,$F4,$8E,$4B,$02,$68,$60
	;
HeaderEnter
	; Language code starts here

