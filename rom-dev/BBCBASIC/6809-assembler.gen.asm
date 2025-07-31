

*********************************************************
* P A R S E   T A B L E
*********************************************************

assParseTbl

	********** A **********
assParseTbl_A
assParseTbl_ABX
assParseTbl_ABX_IX	EQU	$00
		FDB	$0458		; [00] - ABX
		FCB	$3A		; base op
assParseTbl_DAA
assParseTbl_DAA_IX	EQU	$01
		FDB	$1021		; [01] - DAA
		FCB	$19		; base op
assParseTbl_NOP
assParseTbl_NOP_IX	EQU	$02
		FDB	$39F0		; [02] - NOP
		FCB	$12		; base op
assParseTbl_RTI
assParseTbl_RTI_IX	EQU	$03
		FDB	$4A89		; [03] - RTI
		FCB	$3B		; base op
assParseTbl_RTS
assParseTbl_RTS_IX	EQU	$04
		FDB	$4A93		; [04] - RTS
		FCB	$39		; base op

	********** A1 **********
assParseTbl_A1
assParseTbl_SYN
assParseTbl_SYN_IX	EQU	$05
		FDB	$4F2E		; [05] - SYN
		FCB	$13		; base op

	********** A2 **********
assParseTbl_A2
assParseTbl_SEX
assParseTbl_SEX_IX	EQU	$06
		FDB	$4CB8		; [06] - SEX
		FCB	$1D		; base op

	********** B **********
assParseTbl_B
assParseTbl_ADC
assParseTbl_ADC_IX	EQU	$07
		FDB	$0483		; [07] - ADC
		FCB	$89		; base op
assParseTbl_EOR
assParseTbl_EOR_IX	EQU	$08
		FDB	$15F2		; [08] - EOR
		FCB	$88		; base op
assParseTbl_SBC
assParseTbl_SBC_IX	EQU	$09
		FDB	$4C43		; [09] - SBC
		FCB	$82		; base op

	********** B2 **********
assParseTbl_B2
assParseTbl_AND
assParseTbl_AND_IX	EQU	$0A
		FDB	$05C4		; [0A] - AND
		FCB	$84		; base op
assParseTbl_OR
assParseTbl_OR_IX	EQU	$0B
		FDB	$01F2		; [0B] - OR
		FCB	$8A		; base op

	********** C **********
assParseTbl_C
assParseTbl_ADD
assParseTbl_ADD_IX	EQU	$0C
		FDB	$0484		; [0C] - ADD
		FCB	$8B		; base op

	********** DIR **********
assParseTbl_DIR
assParseTbl_OPT
assParseTbl_OPT_IX	EQU	$0D
		FDB	$3E14		; [0D] - OPT
		FCB	$00		; base op
assParseTbl_EQU
assParseTbl_EQU_IX	EQU	$0E
		FDB	$1635		; [0E] - EQU
		FCB	$01		; base op
assParseTbl_DCB
assParseTbl_DCB_IX	EQU	$0F
		FDB	$1062		; [0F] - DCB
		FCB	$02		; base op
assParseTbl_DCW
assParseTbl_DCW_IX	EQU	$10
		FDB	$1077		; [10] - DCW
		FCB	$03		; base op
assParseTbl_DCD
assParseTbl_DCD_IX	EQU	$11
		FDB	$1064		; [11] - DCD
		FCB	$04		; base op
assParseTbl_SET
assParseTbl_SET_IX	EQU	$12
		FDB	$4CB4		; [12] - SET
		FCB	$05		; base op

	********** E **********
assParseTbl_E
assParseTbl_CWA
assParseTbl_CWA_IX	EQU	$13
		FDB	$0EE1		; [13] - CWA
		FCB	$3C		; base op

	********** F **********
assParseTbl_F
assParseTbl_NEG
assParseTbl_NEG_IX	EQU	$14
		FDB	$38A7		; [14] - NEG
		FCB	$00		; base op
assParseTbl_ASL
assParseTbl_ASL_IX	EQU	$15
		FDB	$066C		; [15] - ASL
		FCB	$08		; base op
assParseTbl_ASR
assParseTbl_ASR_IX	EQU	$16
		FDB	$0672		; [16] - ASR
		FCB	$07		; base op
assParseTbl_LSL
assParseTbl_LSL_IX	EQU	$17
		FDB	$326C		; [17] - LSL
		FCB	$08		; base op

	********** G **********
assParseTbl_G
assParseTbl_BIT
assParseTbl_BIT_IX	EQU	$18
		FDB	$0934		; [18] - BIT
		FCB	$85		; base op

	********** H **********
assParseTbl_H
assParseTbl_CLR
assParseTbl_CLR_IX	EQU	$19
		FDB	$0D92		; [19] - CLR
		FCB	$0F		; base op
assParseTbl_COM
assParseTbl_COM_IX	EQU	$1A
		FDB	$0DED		; [1A] - COM
		FCB	$03		; base op
assParseTbl_DEC
assParseTbl_DEC_IX	EQU	$1B
		FDB	$10A3		; [1B] - DEC
		FCB	$0A		; base op
assParseTbl_INC
assParseTbl_INC_IX	EQU	$1C
		FDB	$25C3		; [1C] - INC
		FCB	$0C		; base op
assParseTbl_TST
assParseTbl_TST_IX	EQU	$1D
		FDB	$5274		; [1D] - TST
		FCB	$0D		; base op

	********** I **********
assParseTbl_I
assParseTbl_CMP
assParseTbl_CMP_IX	EQU	$1E
		FDB	$0DB0		; [1E] - CMP
		FCB	$81		; base op

	********** K **********
assParseTbl_K
assParseTbl_EXG
assParseTbl_EXG_IX	EQU	$1F
		FDB	$1707		; [1F] - EXG
		FCB	$1E		; base op
assParseTbl_TFR
assParseTbl_TFR_IX	EQU	$20
		FDB	$50D2		; [20] - TFR
		FCB	$1F		; base op

	********** L **********
assParseTbl_L
assParseTbl_JMP
assParseTbl_JMP_IX	EQU	$21
		FDB	$29B0		; [21] - JMP
		FCB	$0E		; base op

	********** M **********
assParseTbl_M
assParseTbl_JSR
assParseTbl_JSR_IX	EQU	$22
		FDB	$2A72		; [22] - JSR
		FCB	$9D		; base op

	********** N **********
assParseTbl_N
assParseTbl_LD
assParseTbl_LD_IX	EQU	$23
		FDB	$0184		; [23] - LD
		FCB	$86		; base op

	********** P **********
assParseTbl_P
assParseTbl_LEA
assParseTbl_LEA_IX	EQU	$24
		FDB	$30A1		; [24] - LEA
		FCB	$30		; base op

	********** Q **********
assParseTbl_Q
assParseTbl_LSR
assParseTbl_LSR_IX	EQU	$25
		FDB	$3272		; [25] - LSR
		FCB	$04		; base op
assParseTbl_ROL
assParseTbl_ROL_IX	EQU	$26
		FDB	$49EC		; [26] - ROL
		FCB	$09		; base op
assParseTbl_ROR
assParseTbl_ROR_IX	EQU	$27
		FDB	$49F2		; [27] - ROR
		FCB	$06		; base op

	********** R **********
assParseTbl_R
assParseTbl_MUL
assParseTbl_MUL_IX	EQU	$28
		FDB	$36AC		; [28] - MUL
		FCB	$3D		; base op

	********** S **********
assParseTbl_S
assParseTbl_PSH
assParseTbl_PSH_IX	EQU	$29
		FDB	$4268		; [29] - PSH
		FCB	$34		; base op
assParseTbl_PUL
assParseTbl_PUL_IX	EQU	$2A
		FDB	$42AC		; [2A] - PUL
		FCB	$35		; base op

	********** T **********
assParseTbl_T
assParseTbl_ST
assParseTbl_ST_IX	EQU	$2B
		FDB	$0274		; [2B] - ST
		FCB	$97		; base op

	********** U **********
assParseTbl_U
assParseTbl_BCC
assParseTbl_BCC_IX	EQU	$2C
		FDB	$0863		; [2C] - BCC
		FCB	$24		; base op
assParseTbl_BCS
assParseTbl_BCS_IX	EQU	$2D
		FDB	$0873		; [2D] - BCS
		FCB	$25		; base op
assParseTbl_BEQ
assParseTbl_BEQ_IX	EQU	$2E
		FDB	$08B1		; [2E] - BEQ
		FCB	$27		; base op
assParseTbl_BGE
assParseTbl_BGE_IX	EQU	$2F
		FDB	$08E5		; [2F] - BGE
		FCB	$2C		; base op
assParseTbl_BGT
assParseTbl_BGT_IX	EQU	$30
		FDB	$08F4		; [30] - BGT
		FCB	$2E		; base op
assParseTbl_BHI
assParseTbl_BHI_IX	EQU	$31
		FDB	$0909		; [31] - BHI
		FCB	$22		; base op
assParseTbl_BHS
assParseTbl_BHS_IX	EQU	$32
		FDB	$0913		; [32] - BHS
		FCB	$24		; base op
assParseTbl_BLE
assParseTbl_BLE_IX	EQU	$33
		FDB	$0985		; [33] - BLE
		FCB	$2F		; base op
assParseTbl_BLO
assParseTbl_BLO_IX	EQU	$34
		FDB	$098F		; [34] - BLO
		FCB	$25		; base op
assParseTbl_BLS
assParseTbl_BLS_IX	EQU	$35
		FDB	$0993		; [35] - BLS
		FCB	$23		; base op
assParseTbl_BLT
assParseTbl_BLT_IX	EQU	$36
		FDB	$0994		; [36] - BLT
		FCB	$2D		; base op
assParseTbl_BMI
assParseTbl_BMI_IX	EQU	$37
		FDB	$09A9		; [37] - BMI
		FCB	$2B		; base op
assParseTbl_BNE
assParseTbl_BNE_IX	EQU	$38
		FDB	$09C5		; [38] - BNE
		FCB	$26		; base op
assParseTbl_BPL
assParseTbl_BPL_IX	EQU	$39
		FDB	$0A0C		; [39] - BPL
		FCB	$2A		; base op
assParseTbl_BRA
assParseTbl_BRA_IX	EQU	$3A
		FDB	$0A41		; [3A] - BRA
		FCB	$20		; base op
assParseTbl_BRN
assParseTbl_BRN_IX	EQU	$3B
		FDB	$0A4E		; [3B] - BRN
		FCB	$21		; base op
assParseTbl_BSR
assParseTbl_BSR_IX	EQU	$3C
		FDB	$0A72		; [3C] - BSR
		FCB	$8D		; base op
assParseTbl_BVC
assParseTbl_BVC_IX	EQU	$3D
		FDB	$0AC3		; [3D] - BVC
		FCB	$28		; base op
assParseTbl_BVS
assParseTbl_BVS_IX	EQU	$3E
		FDB	$0AD3		; [3E] - BVS
		FCB	$29		; base op

	********** Y **********
assParseTbl_Y
assParseTbl_SWI
assParseTbl_SWI_IX	EQU	$3F
		FDB	$4EE9		; [3F] - SWI
		FCB	$3F		; base op

	********** Z **********
assParseTbl_Z
assParseTbl_SUB
assParseTbl_SUB_IX	EQU	$40
		FDB	$4EA2		; [40] - SUB
		FCB	$80		; base op

assParseTbl_END	FCB	$FF	; end of table marker




*********************************************************
* S U F F I X    S E T S   T A B L E
*********************************************************

assSuffSetsTbl
		* SUFLIST [01] - LD ABDSUXY*EFWQ BT MD
		* A B D S U X Y
		FCB	$05,$07,$0E,$12,$15,$19,$9E
		* SUFLIST [08] - ADC AB*D R CC
		* CC A B
		FCB	$09,$05,$87
		* SUFLIST [0B] - ABD MD
		* A B D
		FCB	$05,$07,$8F
		* SUFLIST [0E] - SUXY
		* S U X Y
		FCB	$14,$16,$1A,$9D
		* SUFLIST [12] - AB*DW
		* A B
		FCB	$04,$86
		* SUFLIST [14] - 23
		* 2 3 
		FCB	$02,$03,$81
		* SUFLIST [17] - ADD ABD*EFW R
		* D
		FCB	$0B,$FF,$09
		* SUFLIST [1A] - ABD*EFW
		* A B D
		FCB	$04,$06,$8C
		* SUFLIST [1D] - CMP ABDSUXY*EFW R
		* S U X Y D
		FCB	$13,$17,$1B,$1C,$0D,$FF,$09
		* SUFLIST [24] - SUB ABD*EFW R
		* D
		FCB	$0A,$FF,$09
		* SUFLIST [27] - SU
		* S U
		FCB	$11,$98



*********************************************************
* S U F F I X    I T E M   T A B L E
*********************************************************

assSuffItemTbl
		* SUFITEM [01] - 
				; no suff
		FCB	$80	; FLAGS - 
		* SUFITEM [02] - 2
		FCB	$12	; "2"
		FCB	$90	; FLAGS - 10
		* SUFITEM [03] - 3
		FCB	$13	; "3"
		FCB	$91	; FLAGS - 11
		* SUFITEM [04] - A
		FCB	$41	; "A"
		FCB	$84	; FLAGS - SUF-OP
		FCB	$40	; OP
		* SUFITEM [05] - A
		FCB	$41	; "A"
		FCB	$80	; FLAGS - 
		* SUFITEM [06] - B
		FCB	$42	; "B"
		FCB	$84	; FLAGS - SUF-OP
		FCB	$50	; OP
		* SUFITEM [07] - B
		FCB	$42	; "B"
		FCB	$84	; FLAGS - SUF-OP
		FCB	$40	; OP
		* SUFITEM [08] - C
		FCB	$43	; "C"
		FCB	$80	; FLAGS - 
		* SUFITEM [09] - CC
		FCB	$43,$43	; "CC"
ASS_REGS_CC_IX	EQU	$09
		FCB	$C8	; FLAGS - SUF-MODE EXTRA0-OPMAP
		FCB	$81	; MODE #
		* SUFITEM [0A] - D
		FCB	$44	; "D"
		FCB	$86	; FLAGS - #16 SUF-OP
		FCB	$03	; OP
		* SUFITEM [0B] - D
		FCB	$44	; "D"
		FCB	$86	; FLAGS - #16 SUF-OP
		FCB	$38	; OP
		* SUFITEM [0C] - D
		FCB	$44	; "D"
		FCB	$96	; FLAGS - 10 #16 SUF-OP
		FCB	$40	; OP
		* SUFITEM [0D] - D
		FCB	$44	; "D"
		FCB	$96	; FLAGS - 10 #16 SUF-OP
		FCB	$02	; OP
		* SUFITEM [0E] - D
		FCB	$44	; "D"
		FCB	$86	; FLAGS - #16 SUF-OP
		FCB	$46	; OP
		* SUFITEM [0F] - D
		FCB	$44	; "D"
		FCB	$92	; FLAGS - 10 #16
		* SUFITEM [10] - I
		FCB	$49	; "I"
		FCB	$80	; FLAGS - 
		* SUFITEM [11] - S
		FCB	$53	; "S"
		FCB	$82	; FLAGS - #16
		* SUFITEM [12] - S
		FCB	$53	; "S"
		FCB	$96	; FLAGS - 10 #16 SUF-OP
		FCB	$48	; OP
		* SUFITEM [13] - S
		FCB	$53	; "S"
		FCB	$97	; FLAGS - 11 #16 SUF-OP
		FCB	$0B	; OP
		* SUFITEM [14] - S
		FCB	$53	; "S"
		FCB	$86	; FLAGS - #16 SUF-OP
		FCB	$02	; OP
		* SUFITEM [15] - U
		FCB	$55	; "U"
		FCB	$86	; FLAGS - #16 SUF-OP
		FCB	$48	; OP
		* SUFITEM [16] - U
		FCB	$55	; "U"
		FCB	$86	; FLAGS - #16 SUF-OP
		FCB	$03	; OP
		* SUFITEM [17] - U
		FCB	$55	; "U"
		FCB	$97	; FLAGS - 11 #16 SUF-OP
		FCB	$02	; OP
		* SUFITEM [18] - U
		FCB	$55	; "U"
		FCB	$86	; FLAGS - #16 SUF-OP
		FCB	$02	; OP
		* SUFITEM [19] - X
		FCB	$58	; "X"
		FCB	$86	; FLAGS - #16 SUF-OP
		FCB	$08	; OP
		* SUFITEM [1A] - X
		FCB	$58	; "X"
		FCB	$82	; FLAGS - #16
		* SUFITEM [1B] - X
		FCB	$58	; "X"
		FCB	$86	; FLAGS - #16 SUF-OP
		FCB	$0B	; OP
		* SUFITEM [1C] - Y
		FCB	$59	; "Y"
		FCB	$96	; FLAGS - 10 #16 SUF-OP
		FCB	$0B	; OP
		* SUFITEM [1D] - Y
		FCB	$59	; "Y"
		FCB	$86	; FLAGS - #16 SUF-OP
		FCB	$01	; OP
		* SUFITEM [1E] - Y
		FCB	$59	; "Y"
		FCB	$96	; FLAGS - 10 #16 SUF-OP
		FCB	$08	; OP


*********************************************************
* C L A S S   T A B L E
*********************************************************

assClassTbl
assClass_A_ix	equ	$00	; class #assClassTbl_A
		FCB	$05	; max index
		FCB	$80	; flags
		FCB	$00	; suffix set
		FCB	$00	; mode set
assClass_A1_ix	equ	$01	; class #assClassTbl_A1
		FCB	$06	; max index
		FCB	$88	; flags
		FCB	$88	; suffix set
		FCB	$00	; mode set
assClass_A2_ix	equ	$02	; class #assClassTbl_A2
		FCB	$07	; max index
		FCB	$88	; flags
		FCB	$81	; suffix set
		FCB	$00	; mode set
assClass_B_ix	equ	$03	; class #assClassTbl_B
		FCB	$0A	; max index
		FCB	$88	; flags
		FCB	$09	; suffix set
		FCB	$1F	; mode set
assClass_B2_ix	equ	$04	; class #assClassTbl_B2
		FCB	$0C	; max index
		FCB	$88	; flags
		FCB	$08	; suffix set
		FCB	$1F	; mode set
assClass_C_ix	equ	$05	; class #assClassTbl_C
		FCB	$0D	; max index
		FCB	$88	; flags
		FCB	$17	; suffix set
		FCB	$1F	; mode set
assClass_DIR_ix	equ	$06	; class #assClassTbl_DIR
		FCB	$13	; max index
		FCB	$80	; flags
		FCB	$00	; suffix set
		FCB	$00	; mode set
assClass_E_ix	equ	$07	; class #assClassTbl_E
		FCB	$14	; max index
		FCB	$88	; flags
		FCB	$90	; suffix set
		FCB	$81	; mode set
assClass_F_ix	equ	$08	; class #assClassTbl_F
		FCB	$18	; max index
		FCB	$80	; flags
		FCB	$12	; suffix set
		FCB	$3E	; mode set
assClass_G_ix	equ	$09	; class #assClassTbl_G
		FCB	$19	; max index
		FCB	$88	; flags
		FCB	$0B	; suffix set
		FCB	$1F	; mode set
assClass_H_ix	equ	$0A	; class #assClassTbl_H
		FCB	$1E	; max index
		FCB	$80	; flags
		FCB	$1A	; suffix set
		FCB	$3E	; mode set
assClass_I_ix	equ	$0B	; class #assClassTbl_I
		FCB	$1F	; max index
		FCB	$88	; flags
		FCB	$1D	; suffix set
		FCB	$1F	; mode set
assClass_K_ix	equ	$0C	; class #assClassTbl_K
		FCB	$21	; max index
		FCB	$80	; flags
		FCB	$00	; suffix set
		FCB	$82	; mode set
assClass_L_ix	equ	$0D	; class #assClassTbl_L
		FCB	$22	; max index
		FCB	$80	; flags
		FCB	$00	; suffix set
		FCB	$3E	; mode set
assClass_M_ix	equ	$0E	; class #assClassTbl_M
		FCB	$23	; max index
		FCB	$80	; flags
		FCB	$00	; suffix set
		FCB	$4E	; mode set
assClass_N_ix	equ	$0F	; class #assClassTbl_N
		FCB	$24	; max index
		FCB	$88	; flags
		FCB	$01	; suffix set
		FCB	$1F	; mode set
assClass_P_ix	equ	$10	; class #assClassTbl_P
		FCB	$25	; max index
		FCB	$88	; flags
		FCB	$0E	; suffix set
		FCB	$04	; mode set
assClass_Q_ix	equ	$11	; class #assClassTbl_Q
		FCB	$28	; max index
		FCB	$80	; flags
		FCB	$12	; suffix set
		FCB	$3E	; mode set
assClass_R_ix	equ	$12	; class #assClassTbl_R
		FCB	$29	; max index
		FCB	$88	; flags
		FCB	$81	; suffix set
		FCB	$00	; mode set
assClass_S_ix	equ	$13	; class #assClassTbl_S
		FCB	$2B	; max index
		FCB	$88	; flags
		FCB	$27	; suffix set
		FCB	$83	; mode set
assClass_T_ix	equ	$14	; class #assClassTbl_T
		FCB	$2C	; max index
		FCB	$88	; flags
		FCB	$01	; suffix set
		FCB	$4E	; mode set
assClass_U_ix	equ	$15	; class #assClassTbl_U
		FCB	$3F	; max index
		FCB	$80	; flags
		FCB	$00	; suffix set
		FCB	$80	; mode set
assClass_Y_ix	equ	$16	; class #assClassTbl_Y
		FCB	$40	; max index
		FCB	$88	; flags
		FCB	$14	; suffix set
		FCB	$00	; mode set
assClass_Z_ix	equ	$17	; class #assClassTbl_Z
		FCB	$41	; max index
		FCB	$88	; flags
		FCB	$24	; suffix set
		FCB	$1F	; mode set
assClassTbl_END




*********************************************************
* M O D E    T A B L E 
*********************************************************

assModeTbl
		fcb	$12	; # dp ix ex [dp]
		fcb	$10	; OP
		fcb	$00	; FLAGS
		fcb	$14	; # dp ix ex [ix]
		fcb	$20	; OP
		fcb	$00	; FLAGS
		fcb	$18	; # dp ix ex [ex]
		fcb	$30	; OP
		fcb	$00	; FLAGS
		fcb	$44	; ST dp ix ex [ix]
		fcb	$10	; OP
		fcb	$00	; FLAGS
		fcb	$48	; ST dp ix ex [ex]
		fcb	$20	; OP
		fcb	$00	; FLAGS
		fcb	$34	; dp ix ex [ix]
		fcb	$60	; OP
		fcb	$00	; FLAGS
		fcb	$38	; dp ix ex [ex]
		fcb	$70	; OP
		fcb	$00	; FLAGS
		FCB 0; EOT


ASS_MODESET_IMMEDONLY	equ	$81
ASS_MODESET_ANY1	equ	$1F
ASS_MODESET_MEM2	equ	$4E
ASS_MODESET_W	equ	$83
ASS_MODESET_MEM1	equ	$3E
ASS_MODESET_INDEXONLY	equ	$04
ASS_MODESET_REGREG	equ	$82
ASS_MODESET_REL	equ	$80
ASS_MODESET_BITBIT	equ	$84
ASS_MODESET_TFM	equ	$85
ASS_MODESET_IMPLIED	equ	$00


*********************************************************
* C C    O P S
*********************************************************

assXlateCC
		fcb	$02	; size
		fcb	$84	; op org
		fcb	$1C	; op new
		fcb	$8A	; op org
		fcb	$1A	; op new
ASS_MNE_BITS	equ	$00007FFF	; bits used in mnemonics
ASS_BITS_PRE	equ	$11	; bits set indicate prefix
ASS_BITS_PRE_10	equ	$10	; prefix = $10
ASS_BITS_PRE_11	equ	$11	; prefix = $10
ASS_BITS_EXTRA0	equ	$40	; EXTRA0 only
ASS_BITS_BOTH	equ	$08	; BOTH suffix and mode required
ASS_BITS_16B	equ	$02	; immediate values 16 bits

FLAGS_SUF_ANY	equ	$0C	; suffix specific bits
FLAGS_SUF_OP	equ	$04	; suffix followed by OP code delta
FLAGS_SUF_MODE	equ	$08	; suffix followed by mode override

ASS_CLSTBL_SIZE	equ	$04	; class table entry size
ASS_CLSTBL_OF_IXMAX	equ	$00	; offset ixmax
ASS_CLSTBL_OF_FLAGS	equ	$01	; offset flags
ASS_CLSTBL_OF_SUFS	equ	$02	; offset suffix set
ASS_CLSTBL_OF_MODES	equ	$03	; offset suffix set

ASS_OPTBL_SIZE	equ	$03	; opcode/mne table entry size
ASS_OPTBL_OF_MNE	equ	$00	; offset mne hash (2)
ASS_OPTBL_OF_OP	equ	$02	; offset base opcode

ASS_MEMPB_IND	equ	$10	;IX,INDIRECT FLAG
ASS_MEMPB_SZ8	equ	$20	;IX,FORCE 8
ASS_MEMPB_SZ16	equ	$40	;IX,FORCE 16
ASS_MEMPB_IMM	equ	$01	;IMMEDIATE
ASS_MEMPB_DP	equ	$02	;DIRECT PAGE
ASS_MEMPB_IX	equ	$04	;INDEX/INDIRECT
ASS_MEMPB_EXT	equ	$08	;EXTENDED
