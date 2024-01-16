.syntax unified
.thumb

.text

@ NOTES:
@ r0, r5, r12 are scratch registers
@ r1, r2, r3, r6, r7, r8, r9, r10, r11 are required/reserved
@ current op register (r6) can be re-used as a scratch register after the op is read
progc .req r1
stackptr .req r2
cpuregs .req r3
args .req r4
gbc_op .req r6
cpuflags .req r7
mem_catch_read_reg .req r8
mem_catch_write_reg .req r9
cartaddr .req r10
xlbl_addr .req r11
sc0 .req r0
sc1 .req r5
sc3 .req gbc_op @ CLOBBERED WITH CURRENT OP REGISTER
sc2 .req r12


.macro get_opmi
	ldrbmi gbc_op,[progc],1
	ldrmi pc,[xlbl_addr,gbc_op,lsl 2]
.endm

.macro get_oplt
	ldrblt gbc_op,[progc],1
	ldrlt pc,[xlbl_addr,gbc_op,lsl 2]
.endm

.macro get_opeq
	ldrbeq gbc_op,[progc],1
	ldreq pc,[xlbl_addr,gbc_op,lsl 2]
.endm

@@@ CPU FLAGS MACROS
.equ zflag_clear, 0x7f
.equ zflag_set, 0x80
.equ nflag_clear, 0xbf
.equ nflag_set, 0x40
.equ hflag_clear, 0xdf
.equ hflag_set, 0x20
.equ cflag_clear, 0xef
.equ cflag_set, 0x10

@@@ CPU REGS MACROS
.equ A_reg, 7
.equ B_reg, 1
.equ C_reg, 0
.equ D_reg, 3
.equ E_reg, 2
.equ F_reg, 6
.equ H_reg, 5
.equ L_reg, 4
.equ BC_reg, 0
.equ DE_reg, 2
.equ HL_reg, 4
.equ AF_reg, 6
.equ wram0_reg, 8
.equ wramn_reg, 12
.equ vramn_reg, 16
.equ SC_reg, 20

.macro get_1_arg_signed
	ldrsb args,[progc],1
.endm

.macro get_1_arg
	ldrb args,[progc],1
.endm

.macro get_2_arg
	ldrh args,[progc],2
.endm

.macro set_nflag
	orr cpuflags,nflag_set
.endm

.macro set_hflag
	orr cpuflags,hflag_set
.endm

.macro set_cflag
	orr cpuflags,cflag_set
.endm

.macro set_zflag
	orr cpuflags,zflag_set
.endm

.macro clear_nflag
	and cpuflags,nflag_clear
.endm

.macro clear_hflag
	and cpuflags,hflag_clear
.endm

.macro clear_cflag
	and cpuflags,cflag_clear
.endm

.macro clear_zflag
	and cpuflags,zflag_clear
.endm

@@@@@@@@@@@@@ NOTES @@@@@@@@@@@@@@
@ Only when a number is added to itself, the hflag can be checked by testing the result with 0x10


.macro set_z_eq
	ite eq
	orreq cpuflags,zflag_set
	andne cpuflags,zflag_clear	
.endm

.macro set_h_eq
	ite eq
	orreq cpuflags,hflag_set
	andne cpuflags,hflag_clear
.endm

.macro set_c_eq
	ite eq
	orreq cpuflags,cflag_set
	andne cpuflags,cflag_clear
.endm

.macro ld_reg8_d8 dstreg
	strb args,[cpuregs,\dstreg]
.endm

.macro ld_reg8_reg8 dstreg,srcreg 
	ldrb sc0,[cpuregs,\srcreg]
	strb sc0,[cpuregs,\dstreg]
.endm

.macro inc_reg8 regname
	ldrb sc0,[cpuregs,\regname] @ sc0 has previous value of reg
	add sc0,1
	strb sc0,[cpuregs,\regname]
	tst sc0,0xf    @ h-flag: a carry from bit 3 will only happen if bits 3:0 are 1
	set_h_eq
	tst sc0,0xff   @ z-flag: zero if all 8 bits are 1
	set_z_eq
	clear_nflag
.endm

.macro dec_reg8 regname
	ldrb sc0,[cpuregs,\regname]
	subs sc0,1
	strb sc0,[cpuregs,\regname]
	set_z_eq
	and sc0,0xf
	teq sc0,0xf    @ borrow from 4 can only happen if bits 3:0 are 0
	set_h_eq
	set_nflag
.endm

.macro inc_reg16 regname
	ldrh sc0,[cpuregs,\regname]
	add sc0,1
	strh sc0,[cpuregs,\regname]
.endm

.macro dec_reg16 regname
	ldrh sc0,[cpuregs,\regname]
	sub sc0,1
	strh sc0,[cpuregs,\regname]
.endm

.macro add_reg8_reg8 dstreg,srcreg
	ldrb sc0,[cpuregs,\dstreg]
	ldrb sc1,[cpuregs,\srcreg]
	mov sc2,sc0					@ sc2 holds the pre-op value of rA
	add sc0,sc1					@ sc0 holds the post-op value
	strb sc0,[cpuregs,\dstreg]
	tst sc0,0x100				@ cflag
	set_c_eq
	tst sc0,0xff				@ zflag
	set_z_eq
	and sc2,0xf					@ hflag
	and sc1,0xf
	add sc2,sc1
	tst sc2, 0x10
	set_h_eq
	clear_nflag
.endm

.macro adc_reg8_reg8 dstreg,srcreg 
	ldrb sc0,[cpuregs,\dstreg]
	ldrb sc1,[cpuregs,\srcreg]
	mov sc2,sc0					@ sc2 holds the pre-op value of sc0
	add sc0,sc1					@ sc0 holds the post-op value
	tst cpuflags,cflag_set
	it eq
	addeq sc0,1
	strb sc0,[cpuregs,\dstreg]
	tst sc0,0x100				@ cflag
	set_c_eq
	tst sc0,0xff				@ zflag
	set_z_eq
	and sc2,0xf					@ hflag
	and sc1,0xf
	add sc2,sc1
	tst sc2, 0x10
	set_h_eq
	clear_nflag
.endm

@Writing specific instructions for adding reg A to reg A saves space
.macro add_regA_regA		
	ldrb sc0,[cpuregs,A_reg]
	lsl sc0,2					
	strb sc0,[cpuregs,A_reg]
	tst sc0,0x100				@ cflag
	set_c_eq
	tst sc0,0xff				@ zflag
	set_z_eq
	tst sc0, 0x10				@ hflag
	set_h_eq
	clear_nflag
.endm

.macro adc_regA_regA
	ldrb sc0,[cpuregs,A_reg]
	lsl sc0,2   
	tst cpuflags,cflag_set
	it eq
	addeq sc0,1
	strb sc0,[cpuregs,A_reg]
	tst sc0,0x100				@ cflag
	set_c_eq
	tst sc0,0xff				@ zflag
	set_z_eq
	tst sc0, 0x10				@ hflag
	set_h_eq
	clear_nflag
.endm

.macro sub_A_reg8 regname			@ regname is reg being subtracted from A
	ldrb sc0,[cpuregs,A_reg]
	ldrb sc1,[cpuregs,\regname]
	mov sc2,sc0
	subs sc0,sc1
	strb sc0,[cpuregs,A_reg]
	set_z_eq
	ite mi							@ if the result is negative, this will be true (a borrow happened)
	andmi cpuflags,cflag_clear		@ the cflag is cleared if a borrow occurred
	orrpl cpuflags,cflag_set		@ the cflag is set if a borrow did not occur	
	and sc2,0xf						@ hflag
	and sc1,0xf
	cmp sc2,sc1
	ite mi
	andmi cpuflags,hflag_clear
	orrpl cpuflags,hflag_set
	set_nflag
.endm

.macro sbc_A_reg8 regname @ regname is reg being subtracted from A
	ldrb sc0,[cpuregs,A_reg]
	ldrb sc1,[cpuregs,\regname]
	mov sc2,sc0
	tst cpuflags,cflag_set
	it eq
	subeq sc0,1
	subs sc0,sc1							@ do this subtraction last so I can use it to set flags
	strb sc0,[cpuregs,A_reg]
	set_z_eq
	ite mi									@ if the result is negative, this will be true (a borrow happened)
	andmi cpuflags,cflag_clear				@ the cflag is cleared if a borrow occurred
	orrpl cpuflags,cflag_set				@ the cflag is set if a borrow did not occur
	and sc2,sc2,0xf							@ hflag
	and sc1,sc1,0xf
	cmp sc2,sc1
	ite mi
	andmi cpuflags,hflag_clear
	orrpl cpuflags,hflag_set
	set_nflag
.endm

.macro and_A_reg8 regname
	ldrb sc0,[cpuregs,A_reg]
	ldrb sc1,[cpuregs,\regname]
	ands sc1,sc0,sc1
	strb sc1,[cpuregs,A_reg]
	ite eq
	moveq cpuflags,0xa0			@ Z,H = 1; N,C = 0
	movne cpuflags,0x20			@ H = 1; Z,N,C = 0
.endm

.macro add_hl_r16 offset
	ldrh sc0,[cpuregs,HL_reg]
	ldrh sc1,[cpuregs,\offset]
	@Im not doing the h flag right now
	adds sc2,sc0,sc1
.endm


.macro cp_A_reg8 regname
	ldrb sc0,[cpuregs,A_reg]
	ldrb sc1,[cpuregs,\regname]
	cmp sc0,sc1
	ittt eq
	moveq cpuflags,0xc0			@ If they are equal, we can stop early
	get_opeq
	ite mi						@ they are not equal
	movmi cpuflags,0x50			@ negative - N and C flags set
	movpl cpuflags,0x60			@ gt or eq - N set, Z and C flags clear
	and sc0,0xf
	and sc1,0xf
	cmp sc0,sc1
	it mi
	orrmi cpuflags,hflag_set
.endm

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ PREFIX CB MACROS

.macro cb_rlc_r8 regname @ regname is the 8-bit CPU reg
	ldrb sc0,[cpuregs,\regname]
	eor cpuflags,cpuflags
	sxtb sc0,sc0				@ bits 31:8 are the same as bit 7
	rors sc0,sc0,31				@ this should make new b0 same as old b7
	ittt eq						@ if reg is 0, set z flag and then we are done
	orreq cpuflags,zflag_set
	get_opeq
	it cs						@ old b8 == old b7, and old b8 was the last bit shifted through carry in APSR
	orrcs cpuflags,cflag_set	@ set carry flag if carry in APSR is set (carry flag == b7 == b8)
	strb sc0,[cpuregs,\regname]
.endm


.macro cb_reset_bit bitnum,regname
	ldrb sc0,[cpuregs,\regname]
	bic sc0,\bitnum
	strb sc0,[cpuregs,\regname]
.endm


.macro cb_set_bit bitnum,regname
	ldrb sc0,[cpuregs,\regname]
	orr sc0,\bitnum
	strb sc0,[cpuregs,\regname]
.endm


.macro cb_bit bitnum,regname
	ldrb sc0,[cpuregs,\regname]
	tst sc0,\bitnum
	ite ne
	andne cpuflags,zflag_clear
	orreq cpuflags,zflag_set
	clear_nflag
	set_hflag
	strb sc0,[cpuregs,\regname]
.endm


@@ original
@ aaaa bbbb
@@@ result = original | (original << 8)
@ aaaa bbbb aaaa bbbb
@@@ result >> 4
@ bbbb aaaa
.macro cb_swap_r8 regname
	ldrb sc0,[cpuregs,\regname]
	eor cpuflags,cpuflags
	orrs sc0,sc0,sc0, lsl 8
	lsr sc0,4
	it eq
	orreq cpuflags,zflag_set
	strb sc0,[cpuregs,\regname]
.endm

.macro cb_srl_r8 regname
	ldrb sc0,[cpuregs,\regname]
	eor cpuflags,cpuflags
	lsrs sc0,sc0,1
	it cs						@old bit 0 is moved to carry flag in APSR
	orrcs cpuflags,cflag_set
	it eq
	orreq cpuflags,zflag_set
	strb sc0,[cpuregs,\regname]
.endm

.macro cb_rrc_r8 regname
	ldrb sc0,[cpuregs,\regname]
	eor cpuflags,cpuflags
	lsrs sc0,sc0,1			
	itt cs
	orrcs cpuflags,cflag_set
	orrcs sc0,sc0,0x80
	it eq
	orreq cpuflags,zflag_set
	strb sc0,[cpuregs,\regname]
.endm

.macro cb_rl_r8 regname

.endm

.macro cb_rr_r8 regname

.endm

.macro cb_sla_r8 regname

.endm

.macro cb_sra_r8 regname
	ldrb sc0,[cpuregs,\regname]
	eor cpuflags,cpuflags
	lsrs sc0,sc0,1					@moves old bit 0 to carry flag in APSR
	it cs							@carry flag = old b0
	orrcs cpuflags,cflag_set
	it eq							@z flag if 0
	orreq cpuflags,zflag_set
	tst sc0,0x40					@check if old bit 7 was set, set new bit 7 if true
	it ne							@b7 = old b7
	orrne sc0,sc0,0x80
	strb sc0,[cpuregs,\regname]
.endm

