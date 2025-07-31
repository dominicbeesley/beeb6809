

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

	********** D **********
assParseTbl_D
assParseTbl_AIM
assParseTbl_AIM_IX	EQU	$0D
		FDB	$052D		; [0D] - AIM
		FCB	$02		; base op
assParseTbl_EIM
assParseTbl_EIM_IX	EQU	$0E
		FDB	$152D		; [0E] - EIM
		FCB	$05		; base op
assParseTbl_OIM
assParseTbl_OIM_IX	EQU	$0F
		FDB	$3D2D		; [0F] - OIM
		FCB	$01		; base op
assParseTbl_TIM
assParseTbl_TIM_IX	EQU	$10
		FDB	$512D		; [10] - TIM
		FCB	$0B		; base op

	********** DIR **********
assParseTbl_DIR
assParseTbl_OPT
assParseTbl_OPT_IX	EQU	$11
		FDB	$3E14		; [11] - OPT
		FCB	$00		; base op
assParseTbl_EQU
assParseTbl_EQU_IX	EQU	$12
		FDB	$1635		; [12] - EQU
		FCB	$01		; base op
assParseTbl_DCB
assParseTbl_DCB_IX	EQU	$13
		FDB	$1062		; [13] - DCB
		FCB	$02		; base op
assParseTbl_DCW
assParseTbl_DCW_IX	EQU	$14
		FDB	$1077		; [14] - DCW
		FCB	$03		; base op
assParseTbl_DCD
assParseTbl_DCD_IX	EQU	$15
		FDB	$1064		; [15] - DCD
		FCB	$04		; base op
assParseTbl_SET
assParseTbl_SET_IX	EQU	$16
		FDB	$4CB4		; [16] - SET
		FCB	$05		; base op

	********** E **********
assParseTbl_E
assParseTbl_CWA
assParseTbl_CWA_IX	EQU	$17
		FDB	$0EE1		; [17] - CWA
		FCB	$3C		; base op

	********** F **********
assParseTbl_F
assParseTbl_NEG
assParseTbl_NEG_IX	EQU	$18
		FDB	$38A7		; [18] - NEG
		FCB	$00		; base op
assParseTbl_ASL
assParseTbl_ASL_IX	EQU	$19
		FDB	$066C		; [19] - ASL
		FCB	$08		; base op
assParseTbl_ASR
assParseTbl_ASR_IX	EQU	$1A
		FDB	$0672		; [1A] - ASR
		FCB	$07		; base op
assParseTbl_LSL
assParseTbl_LSL_IX	EQU	$1B
		FDB	$326C		; [1B] - LSL
		FCB	$08		; base op

	********** G **********
assParseTbl_G
assParseTbl_BIT
assParseTbl_BIT_IX	EQU	$1C
		FDB	$0934		; [1C] - BIT
		FCB	$85		; base op

	********** H **********
assParseTbl_H
assParseTbl_CLR
assParseTbl_CLR_IX	EQU	$1D
		FDB	$0D92		; [1D] - CLR
		FCB	$0F		; base op
assParseTbl_COM
assParseTbl_COM_IX	EQU	$1E
		FDB	$0DED		; [1E] - COM
		FCB	$03		; base op
assParseTbl_DEC
assParseTbl_DEC_IX	EQU	$1F
		FDB	$10A3		; [1F] - DEC
		FCB	$0A		; base op
assParseTbl_INC
assParseTbl_INC_IX	EQU	$20
		FDB	$25C3		; [20] - INC
		FCB	$0C		; base op
assParseTbl_TST
assParseTbl_TST_IX	EQU	$21
		FDB	$5274		; [21] - TST
		FCB	$0D		; base op

	********** I **********
assParseTbl_I
assParseTbl_CMP
assParseTbl_CMP_IX	EQU	$22
		FDB	$0DB0		; [22] - CMP
		FCB	$81		; base op

	********** J **********
assParseTbl_J
assParseTbl_DIV
assParseTbl_DIV_IX	EQU	$23
		FDB	$1136		; [23] - DIV
		FCB	$8D		; base op

	********** K **********
assParseTbl_K
assParseTbl_EXG
assParseTbl_EXG_IX	EQU	$24
		FDB	$1707		; [24] - EXG
		FCB	$1E		; base op
assParseTbl_TFR
assParseTbl_TFR_IX	EQU	$25
		FDB	$50D2		; [25] - TFR
		FCB	$1F		; base op

	********** L **********
assParseTbl_L
assParseTbl_JMP
assParseTbl_JMP_IX	EQU	$26
		FDB	$29B0		; [26] - JMP
		FCB	$0E		; base op

	********** M **********
assParseTbl_M
assParseTbl_JSR
assParseTbl_JSR_IX	EQU	$27
		FDB	$2A72		; [27] - JSR
		FCB	$9D		; base op

	********** N **********
assParseTbl_N
assParseTbl_LD
assParseTbl_LD_IX	EQU	$28
		FDB	$0184		; [28] - LD
		FCB	$86		; base op

	********** P **********
assParseTbl_P
assParseTbl_LEA
assParseTbl_LEA_IX	EQU	$29
		FDB	$30A1		; [29] - LEA
		FCB	$30		; base op

	********** Q **********
assParseTbl_Q
assParseTbl_LSR
assParseTbl_LSR_IX	EQU	$2A
		FDB	$3272		; [2A] - LSR
		FCB	$04		; base op
assParseTbl_ROL
assParseTbl_ROL_IX	EQU	$2B
		FDB	$49EC		; [2B] - ROL
		FCB	$09		; base op
assParseTbl_ROR
assParseTbl_ROR_IX	EQU	$2C
		FDB	$49F2		; [2C] - ROR
		FCB	$06		; base op

	********** R **********
assParseTbl_R
assParseTbl_MUL
assParseTbl_MUL_IX	EQU	$2D
		FDB	$36AC		; [2D] - MUL
		FCB	$3D		; base op

	********** S **********
assParseTbl_S
assParseTbl_PSH
assParseTbl_PSH_IX	EQU	$2E
		FDB	$4268		; [2E] - PSH
		FCB	$34		; base op
assParseTbl_PUL
assParseTbl_PUL_IX	EQU	$2F
		FDB	$42AC		; [2F] - PUL
		FCB	$35		; base op

	********** T **********
assParseTbl_T
assParseTbl_ST
assParseTbl_ST_IX	EQU	$30
		FDB	$0274		; [30] - ST
		FCB	$97		; base op

	********** U **********
assParseTbl_U
assParseTbl_BCC
assParseTbl_BCC_IX	EQU	$31
		FDB	$0863		; [31] - BCC
		FCB	$24		; base op
assParseTbl_BCS
assParseTbl_BCS_IX	EQU	$32
		FDB	$0873		; [32] - BCS
		FCB	$25		; base op
assParseTbl_BEQ
assParseTbl_BEQ_IX	EQU	$33
		FDB	$08B1		; [33] - BEQ
		FCB	$27		; base op
assParseTbl_BGE
assParseTbl_BGE_IX	EQU	$34
		FDB	$08E5		; [34] - BGE
		FCB	$2C		; base op
assParseTbl_BGT
assParseTbl_BGT_IX	EQU	$35
		FDB	$08F4		; [35] - BGT
		FCB	$2E		; base op
assParseTbl_BHI
assParseTbl_BHI_IX	EQU	$36
		FDB	$0909		; [36] - BHI
		FCB	$22		; base op
assParseTbl_BHS
assParseTbl_BHS_IX	EQU	$37
		FDB	$0913		; [37] - BHS
		FCB	$24		; base op
assParseTbl_BLE
assParseTbl_BLE_IX	EQU	$38
		FDB	$0985		; [38] - BLE
		FCB	$2F		; base op
assParseTbl_BLO
assParseTbl_BLO_IX	EQU	$39
		FDB	$098F		; [39] - BLO
		FCB	$25		; base op
assParseTbl_BLS
assParseTbl_BLS_IX	EQU	$3A
		FDB	$0993		; [3A] - BLS
		FCB	$23		; base op
assParseTbl_BLT
assParseTbl_BLT_IX	EQU	$3B
		FDB	$0994		; [3B] - BLT
		FCB	$2D		; base op
assParseTbl_BMI
assParseTbl_BMI_IX	EQU	$3C
		FDB	$09A9		; [3C] - BMI
		FCB	$2B		; base op
assParseTbl_BNE
assParseTbl_BNE_IX	EQU	$3D
		FDB	$09C5		; [3D] - BNE
		FCB	$26		; base op
assParseTbl_BPL
assParseTbl_BPL_IX	EQU	$3E
		FDB	$0A0C		; [3E] - BPL
		FCB	$2A		; base op
assParseTbl_BRA
assParseTbl_BRA_IX	EQU	$3F
		FDB	$0A41		; [3F] - BRA
		FCB	$20		; base op
assParseTbl_BRN
assParseTbl_BRN_IX	EQU	$40
		FDB	$0A4E		; [40] - BRN
		FCB	$21		; base op
assParseTbl_BSR
assParseTbl_BSR_IX	EQU	$41
		FDB	$0A72		; [41] - BSR
		FCB	$8D		; base op
assParseTbl_BVC
assParseTbl_BVC_IX	EQU	$42
		FDB	$0AC3		; [42] - BVC
		FCB	$28		; base op
assParseTbl_BVS
assParseTbl_BVS_IX	EQU	$43
		FDB	$0AD3		; [43] - BVS
		FCB	$29		; base op

	********** W **********
assParseTbl_W
assParseTbl_BOR
assParseTbl_BOR_IX	EQU	$44
		FDB	$09F2		; [44] - BOR
		FCB	$32		; base op

	********** W1 **********
assParseTbl_W1
assParseTbl_BAN
assParseTbl_BAN_IX	EQU	$45
		FDB	$082E		; [45] - BAN
		FCB	$30		; base op

	********** W2 **********
assParseTbl_W2
assParseTbl_BIA
assParseTbl_BIA_IX	EQU	$46
		FDB	$0921		; [46] - BIA
		FCB	$31		; base op

	********** W3 **********
assParseTbl_W3
assParseTbl_BIO
assParseTbl_BIO_IX	EQU	$47
		FDB	$092F		; [47] - BIO
		FCB	$33		; base op

	********** W4 **********
assParseTbl_W4
assParseTbl_BEO
assParseTbl_BEO_IX	EQU	$48
		FDB	$08AF		; [48] - BEO
		FCB	$34		; base op

	********** W5 **********
assParseTbl_W5
assParseTbl_BIE
assParseTbl_BIE_IX	EQU	$49
		FDB	$0925		; [49] - BIE
		FCB	$35		; base op

	********** X **********
assParseTbl_X
assParseTbl_TFM
assParseTbl_TFM_IX	EQU	$4A
		FDB	$50CD		; [4A] - TFM
		FCB	$38		; base op

	********** Y **********
assParseTbl_Y
assParseTbl_SWI
assParseTbl_SWI_IX	EQU	$4B
		FDB	$4EE9		; [4B] - SWI
		FCB	$3F		; base op

	********** Z **********
assParseTbl_Z
assParseTbl_SUB
assParseTbl_SUB_IX	EQU	$4C
		FDB	$4EA2		; [4C] - SUB
		FCB	$80		; base op

assParseTbl_END	FCB	$FF	; end of table marker




*********************************************************
* S U F F I X    S E T S   T A B L E
*********************************************************

assSuffSetsTbl
		* SUFLIST [01] - LD ABDSUXY*EFWQ BT MD
		* MD Q BT A B D E F W S U X Y
		FCB	$1C,$21,$09,$04,$06,$16,$17,$1A,$2C,$27,$2B,$30,$B4
		* SUFLIST [0E] - ST ABDSUXY*EFWQ BT
		* Q BT
		FCB	$1F,$08,$FF,$04
		* SUFLIST [12] - ADC AB*D R CC
		* CC R A B D
		FCB	$0B,$23,$04,$06,$8F
		* SUFLIST [17] - ABD MD
		* MD A B D
		FCB	$1C,$04,$06,$92
		* SUFLIST [1B] - SEXW
		* W 
		FCB	$2D,$81
		* SUFLIST [1D] - MULD
		* D 
		FCB	$0C,$81
		* SUFLIST [1F] - SUXY
		* S U X Y
		FCB	$26,$29,$2F,$B2
		* SUFLIST [23] - AB*DW
		* A B D W
		FCB	$05,$07,$0D,$AE
		* SUFLIST [27] - 23
		* 2 3 
		FCB	$02,$03,$81
		* SUFLIST [2A] - DQ
		* D Q
		FCB	$15,$A0
		* SUFLIST [2C] - ADD ABD*EFW R
		* D A B E F W R
		FCB	$11,$04,$06,$17,$1A,$2C,$A3
		* SUFLIST [33] - ABD*EFW
		* A B D E F W
		FCB	$05,$07,$0E,$18,$19,$AE
		* SUFLIST [39] - CMP ABDSUXY*EFW R
		* S U X Y D
		FCB	$24,$2A,$31,$33,$13,$FF,$2D
		* SUFLIST [40] - AB*D
		* A B D
		FCB	$05,$07,$8D
		* SUFLIST [43] - SUB ABD*EFW R
		* D
		FCB	$14,$FF,$2D
		* SUFLIST [46] - SU
		* S U
		FCB	$25,$A8



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
		FCB	$80	; FLAGS - 
		* SUFITEM [05] - A
		FCB	$41	; "A"
		FCB	$84	; FLAGS - SUF-OP
		FCB	$40	; OP
		* SUFITEM [06] - B
		FCB	$42	; "B"
		FCB	$84	; FLAGS - SUF-OP
		FCB	$40	; OP
		* SUFITEM [07] - B
		FCB	$42	; "B"
		FCB	$84	; FLAGS - SUF-OP
		FCB	$50	; OP
		* SUFITEM [08] - BT
		FCB	$42,$54	; "BT"
		FCB	$BD	; FLAGS - 11 6309 SUF-OP SUF-MODE
		FCB	$A0	; OP
		FCB	$84	; MODE rr.n,qq.k
		* SUFITEM [09] - BT
		FCB	$42,$54	; "BT"
		FCB	$BD	; FLAGS - 11 6309 SUF-OP SUF-MODE
		FCB	$B0	; OP
		FCB	$84	; MODE rr.n,qq.k
		* SUFITEM [0A] - C
		FCB	$43	; "C"
		FCB	$80	; FLAGS - 
		* SUFITEM [0B] - CC
		FCB	$43,$43	; "CC"
ASS_REGS_CC_IX	EQU	$0B
		FCB	$C8	; FLAGS - SUF-MODE EXTRA0-OPMAP
		FCB	$81	; MODE #
		* SUFITEM [0C] - D
		FCB	$44	; "D"
		FCB	$BF	; FLAGS - 11 6309 #16 SUF-OP SUF-MODE
		FCB	$52	; OP
		FCB	$1F	; MODE # dp ix ex
		* SUFITEM [0D] - D
		FCB	$44	; "D"
		FCB	$B6	; FLAGS - 10 6309 #16 SUF-OP
		FCB	$40	; OP
		* SUFITEM [0E] - D
		FCB	$44	; "D"
		FCB	$96	; FLAGS - 10 #16 SUF-OP
		FCB	$40	; OP
		* SUFITEM [0F] - D
		FCB	$44	; "D"
		FCB	$B2	; FLAGS - 10 6309 #16
		* SUFITEM [10] - D
		FCB	$44	; "D"
		FCB	$80	; FLAGS - 
		* SUFITEM [11] - D
		FCB	$44	; "D"
		FCB	$86	; FLAGS - #16 SUF-OP
		FCB	$38	; OP
		* SUFITEM [12] - D
		FCB	$44	; "D"
		FCB	$92	; FLAGS - 10 #16
		* SUFITEM [13] - D
		FCB	$44	; "D"
		FCB	$96	; FLAGS - 10 #16 SUF-OP
		FCB	$02	; OP
		* SUFITEM [14] - D
		FCB	$44	; "D"
		FCB	$86	; FLAGS - #16 SUF-OP
		FCB	$03	; OP
		* SUFITEM [15] - D
		FCB	$44	; "D"
		FCB	$B1	; FLAGS - 11 6309
		* SUFITEM [16] - D
		FCB	$44	; "D"
		FCB	$86	; FLAGS - #16 SUF-OP
		FCB	$46	; OP
		* SUFITEM [17] - E
		FCB	$45	; "E"
		FCB	$B1	; FLAGS - 11 6309
		* SUFITEM [18] - E
		FCB	$45	; "E"
		FCB	$B5	; FLAGS - 11 6309 SUF-OP
		FCB	$40	; OP
		* SUFITEM [19] - F
		FCB	$46	; "F"
		FCB	$B5	; FLAGS - 11 6309 SUF-OP
		FCB	$50	; OP
		* SUFITEM [1A] - F
		FCB	$46	; "F"
		FCB	$B5	; FLAGS - 11 6309 SUF-OP
		FCB	$40	; OP
		* SUFITEM [1B] - I
		FCB	$49	; "I"
		FCB	$80	; FLAGS - 
		* SUFITEM [1C] - MD
		FCB	$4D,$44	; "MD"
		FCB	$BD	; FLAGS - 11 6309 SUF-OP SUF-MODE
		FCB	$B7	; OP
		FCB	$81	; MODE #
		* SUFITEM [1D] - ND
		FCB	$4E,$44	; "ND"
		FCB	$80	; FLAGS - 
		* SUFITEM [1E] - OR
		FCB	$4F,$52	; "OR"
		FCB	$80	; FLAGS - 
		* SUFITEM [1F] - Q
		FCB	$51	; "Q"
		FCB	$B4	; FLAGS - 10 6309 SUF-OP
		FCB	$46	; OP
		* SUFITEM [20] - Q
		FCB	$51	; "Q"
		FCB	$B7	; FLAGS - 11 6309 #16 SUF-OP
		FCB	$01	; OP
		* SUFITEM [21] - Q
		FCB	$51	; "Q"
		FCB	$B4	; FLAGS - 10 6309 SUF-OP
		FCB	$47	; OP
		* SUFITEM [22] - R
		FCB	$52	; "R"
		FCB	$80	; FLAGS - 
		* SUFITEM [23] - R
		FCB	$52	; "R"
ASS_REGS_REGREG_IX	EQU	$23
		FCB	$F8	; FLAGS - 10 6309 SUF-MODE EXTRA0-OPMAP
		FCB	$82	; MODE r,r
		* SUFITEM [24] - S
		FCB	$53	; "S"
		FCB	$97	; FLAGS - 11 #16 SUF-OP
		FCB	$0B	; OP
		* SUFITEM [25] - S
		FCB	$53	; "S"
		FCB	$82	; FLAGS - #16
		* SUFITEM [26] - S
		FCB	$53	; "S"
		FCB	$86	; FLAGS - #16 SUF-OP
		FCB	$02	; OP
		* SUFITEM [27] - S
		FCB	$53	; "S"
		FCB	$96	; FLAGS - 10 #16 SUF-OP
		FCB	$48	; OP
		* SUFITEM [28] - U
		FCB	$55	; "U"
		FCB	$86	; FLAGS - #16 SUF-OP
		FCB	$02	; OP
		* SUFITEM [29] - U
		FCB	$55	; "U"
		FCB	$86	; FLAGS - #16 SUF-OP
		FCB	$03	; OP
		* SUFITEM [2A] - U
		FCB	$55	; "U"
		FCB	$97	; FLAGS - 11 #16 SUF-OP
		FCB	$02	; OP
		* SUFITEM [2B] - U
		FCB	$55	; "U"
		FCB	$86	; FLAGS - #16 SUF-OP
		FCB	$48	; OP
		* SUFITEM [2C] - W
		FCB	$57	; "W"
		FCB	$B2	; FLAGS - 10 6309 #16
		* SUFITEM [2D] - W
		FCB	$57	; "W"
		FCB	$A4	; FLAGS - 6309 SUF-OP
		FCB	$F7	; OP
		* SUFITEM [2E] - W
		FCB	$57	; "W"
		FCB	$B6	; FLAGS - 10 6309 #16 SUF-OP
		FCB	$50	; OP
		* SUFITEM [2F] - X
		FCB	$58	; "X"
		FCB	$82	; FLAGS - #16
		* SUFITEM [30] - X
		FCB	$58	; "X"
		FCB	$86	; FLAGS - #16 SUF-OP
		FCB	$08	; OP
		* SUFITEM [31] - X
		FCB	$58	; "X"
		FCB	$86	; FLAGS - #16 SUF-OP
		FCB	$0B	; OP
		* SUFITEM [32] - Y
		FCB	$59	; "Y"
		FCB	$86	; FLAGS - #16 SUF-OP
		FCB	$01	; OP
		* SUFITEM [33] - Y
		FCB	$59	; "Y"
		FCB	$96	; FLAGS - 10 #16 SUF-OP
		FCB	$0B	; OP
		* SUFITEM [34] - Y
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
		FCB	$8A	; suffix set
		FCB	$00	; mode set
assClass_A2_ix	equ	$02	; class #assClassTbl_A2
		FCB	$07	; max index
		FCB	$88	; flags
		FCB	$1B	; suffix set
		FCB	$00	; mode set
assClass_B_ix	equ	$03	; class #assClassTbl_B
		FCB	$0A	; max index
		FCB	$88	; flags
		FCB	$13	; suffix set
		FCB	$1F	; mode set
assClass_B2_ix	equ	$04	; class #assClassTbl_B2
		FCB	$0C	; max index
		FCB	$88	; flags
		FCB	$12	; suffix set
		FCB	$1F	; mode set
assClass_C_ix	equ	$05	; class #assClassTbl_C
		FCB	$0D	; max index
		FCB	$88	; flags
		FCB	$2C	; suffix set
		FCB	$1F	; mode set
assClass_D_ix	equ	$06	; class #assClassTbl_D
		FCB	$11	; max index
		FCB	$A0	; flags
		FCB	$00	; suffix set
		FCB	$3E	; mode set
assClass_DIR_ix	equ	$07	; class #assClassTbl_DIR
		FCB	$17	; max index
		FCB	$80	; flags
		FCB	$00	; suffix set
		FCB	$00	; mode set
assClass_E_ix	equ	$08	; class #assClassTbl_E
		FCB	$18	; max index
		FCB	$88	; flags
		FCB	$9B	; suffix set
		FCB	$81	; mode set
assClass_F_ix	equ	$09	; class #assClassTbl_F
		FCB	$1C	; max index
		FCB	$80	; flags
		FCB	$40	; suffix set
		FCB	$3E	; mode set
assClass_G_ix	equ	$0A	; class #assClassTbl_G
		FCB	$1D	; max index
		FCB	$88	; flags
		FCB	$17	; suffix set
		FCB	$1F	; mode set
assClass_H_ix	equ	$0B	; class #assClassTbl_H
		FCB	$22	; max index
		FCB	$80	; flags
		FCB	$33	; suffix set
		FCB	$3E	; mode set
assClass_I_ix	equ	$0C	; class #assClassTbl_I
		FCB	$23	; max index
		FCB	$88	; flags
		FCB	$39	; suffix set
		FCB	$1F	; mode set
assClass_J_ix	equ	$0D	; class #assClassTbl_J
		FCB	$24	; max index
		FCB	$A8	; flags
		FCB	$2A	; suffix set
		FCB	$1F	; mode set
assClass_K_ix	equ	$0E	; class #assClassTbl_K
		FCB	$26	; max index
		FCB	$80	; flags
		FCB	$00	; suffix set
		FCB	$82	; mode set
assClass_L_ix	equ	$0F	; class #assClassTbl_L
		FCB	$27	; max index
		FCB	$80	; flags
		FCB	$00	; suffix set
		FCB	$3E	; mode set
assClass_M_ix	equ	$10	; class #assClassTbl_M
		FCB	$28	; max index
		FCB	$80	; flags
		FCB	$00	; suffix set
		FCB	$4E	; mode set
assClass_N_ix	equ	$11	; class #assClassTbl_N
		FCB	$29	; max index
		FCB	$88	; flags
		FCB	$01	; suffix set
		FCB	$1F	; mode set
assClass_P_ix	equ	$12	; class #assClassTbl_P
		FCB	$2A	; max index
		FCB	$88	; flags
		FCB	$1F	; suffix set
		FCB	$04	; mode set
assClass_Q_ix	equ	$13	; class #assClassTbl_Q
		FCB	$2D	; max index
		FCB	$80	; flags
		FCB	$23	; suffix set
		FCB	$3E	; mode set
assClass_R_ix	equ	$14	; class #assClassTbl_R
		FCB	$2E	; max index
		FCB	$88	; flags
		FCB	$1D	; suffix set
		FCB	$00	; mode set
assClass_S_ix	equ	$15	; class #assClassTbl_S
		FCB	$30	; max index
		FCB	$88	; flags
		FCB	$46	; suffix set
		FCB	$83	; mode set
assClass_T_ix	equ	$16	; class #assClassTbl_T
		FCB	$31	; max index
		FCB	$88	; flags
		FCB	$0E	; suffix set
		FCB	$4E	; mode set
assClass_U_ix	equ	$17	; class #assClassTbl_U
		FCB	$44	; max index
		FCB	$80	; flags
		FCB	$00	; suffix set
		FCB	$80	; mode set
assClass_W_ix	equ	$18	; class #assClassTbl_W
		FCB	$45	; max index
		FCB	$A8	; flags
		FCB	$00	; suffix set
		FCB	$84	; mode set
assClass_W1_ix	equ	$19	; class #assClassTbl_W1
		FCB	$46	; max index
		FCB	$A8	; flags
		FCB	$90	; suffix set
		FCB	$84	; mode set
assClass_W2_ix	equ	$1A	; class #assClassTbl_W2
		FCB	$47	; max index
		FCB	$A8	; flags
		FCB	$9D	; suffix set
		FCB	$84	; mode set
assClass_W3_ix	equ	$1B	; class #assClassTbl_W3
		FCB	$48	; max index
		FCB	$A8	; flags
		FCB	$A2	; suffix set
		FCB	$84	; mode set
assClass_W4_ix	equ	$1C	; class #assClassTbl_W4
		FCB	$49	; max index
		FCB	$A8	; flags
		FCB	$A2	; suffix set
		FCB	$84	; mode set
assClass_W5_ix	equ	$1D	; class #assClassTbl_W5
		FCB	$4A	; max index
		FCB	$A8	; flags
		FCB	$9E	; suffix set
		FCB	$84	; mode set
assClass_X_ix	equ	$1E	; class #assClassTbl_X
		FCB	$4B	; max index
		FCB	$A0	; flags
		FCB	$00	; suffix set
		FCB	$85	; mode set
assClass_Y_ix	equ	$1F	; class #assClassTbl_Y
		FCB	$4C	; max index
		FCB	$88	; flags
		FCB	$27	; suffix set
		FCB	$00	; mode set
assClass_Z_ix	equ	$20	; class #assClassTbl_Z
		FCB	$4D	; max index
		FCB	$88	; flags
		FCB	$43	; suffix set
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
* R E G     R E G    O P S
*********************************************************

assXlateRegReg
		fcb	$08	; size
		fcb	$89	; op org
		fcb	$31	; op new
		fcb	$82	; op org
		fcb	$33	; op new
		fcb	$8B	; op org
		fcb	$30	; op new
		fcb	$8A	; op org
		fcb	$35	; op new
		fcb	$88	; op org
		fcb	$36	; op new
		fcb	$80	; op org
		fcb	$32	; op new
		fcb	$84	; op org
		fcb	$34	; op new
		fcb	$81	; op org
		fcb	$37	; op new


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
ASS_BITS_6309	equ	$20	; 6309 only
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
