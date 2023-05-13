.syntax unified
.thumb

.text

progc .req r1
stackptr .req r2
cpuregs .req r3
args .req r4
gbc_op .req r6
cpuflags .req r7
cartaddr .req r10
xlbl_addr .req r11
sc0 .req r0
sc1 .req r5
sc2 .req r8
sc3 .req r9
sc4 .req r12

.macro get_op
	ldrb gbc_op,[progc],1
	ldr pc,[xlbl_addr,gbc_op,lsl 2]
.endm

.macro get_opmi
	ldrbmi gbc_op,[progc],1
	ldrmi pc,[xlbl_addr,gbc_op]
.endm

.macro get_oplt
	ldrblt gbc_op,[progc],1
	ldrlt pc,[xlbl_addr,gbc_op]
.endm

.equ zflag_clear, 0x7f
.equ zflag_set, 0x80
.equ nflag_clear, 0xbf
.equ nflag_set, 0x40
.equ hflag_clear, 0xdf
.equ hflag_set, 0x20
.equ cflag_clear, 0xef
.equ cflag_set, 0x10
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

.macro get_1_arg
	ldrb args,[progc],1
.endm

.macro get_2_arg
	ldrh args,[progc],2
.endm

.macro set_nflag
	orr cpuregs,nflag_set
.endm

.macro set_hflag
	orr cpuregs,hflag_set
.endm

.macro set_cflag
	orr cpuregs,cflag_set
.endm

.macro set_zflag
	orr cpuregs,zflag_set
.endm

.macro clear_nflag
	and cpuregs,nflag_clear
.endm

.macro clear_hflag
	and cpuregs,hflag_clear
.endm

.macro clear_cflag
	and cpuregs,cflag_clear
.endm

.macro clear_zflag
	and cpuregs,zflag_clear
.endm

@@@@@@@@@@@@@NOTES@@@@@@@@@@@@@@
@Only when a number is added to itself, the hflag can be checked by testing the result with 0x10

.macro set_z_eq
	ite eq
	orreq cpuflags,zflag_set
	andne cpuflags,zflag_clear	
.endm

.macro set_h_eq
	ite eq
	orreq cpuregs,hflag_set
	andne cpuregs,hflag_clear
.endm

.macro set_c_eq
	ite eq
	orreq cpuflags,cflag_set
	andne cpuflags,cflag_clear
.endm

.macro ld_reg8_d8, dstreg  @dstreg is the destination reg
	get_1_arg
	strb args,[cpuregs,\dstreg]
.endm

.macro ld_reg8_reg8, rA,dstreg,srcreg @rA is a free register
	ldrb \rA,[cpuregs,\srcreg]
	strb \rA,[cpuregs,\dstreg]
.endm

.macro inc_reg8, rA,rB, regname  @rA,rB are free registers, regname is the register
	ldrb \rA,[cpuregs,\regname]
	adds \rB,\rA,1
	strb \rB,[cpuregs,\regname]
	cmp \rA,0xf    @h-flag: a carry from bit 3 will only happen if bits 3:0 are 1
	set_h_eq
	cmp \rA,0xff   @z-flag: zero if all 8 bits are 1
	set_z_eq
	clear_nflag
.endm

.macro dec_reg8, rA,rB,regname  @rA,rB are free registers, regname is the register
	ldrb \rA,[cpuregs,\regname]
	subs \rB,\rA,1
	strb \rB,[cpuregs,\regname]
	set_z_eq
	tst \rA,0x0f    @borrow from 4 can only happen if bits 3:0 are 0
	set_h_eq
	set_nflag
.endm

.macro inc_reg16, rA,regname @rA is a free register
	ldrh \rA,[cpuregs,\regname]
	add \rA,\rA,1
	strh \rA,[cpuregs,\regname]
.endm

.macro dec_reg16, rA,regname @rA is a free register
	ldrh \rA,[cpuregs,\regname]
	sub \rA,\rA,1
	strh \rA,[cpuregs,\regname]
.endm

.macro add_reg8_reg8, rA,rB,rC,dstreg,srcreg @rA,rB are free registers
	ldrb \rA,[cpuregs,\dstreg]
	ldrb \rB,[cpuregs,\srcreg]
	mov \rC,\rA    @rC holds the pre-op value of rA
	add \rA,\rB @rA holds the post-op value
	strb \rA,[cpuregs,\dstreg]
	tst \rA,0x100				@cflag
	set_c_eq
	tst \rA,0xff				@zflag
	set_z_eq
	and \rC,0xf					@hflag
	and \rB,0xf
	add \rC,\rB
	tst \rC, 0x10
	set_h_eq
	clear_nflag
.endm

.macro adc_reg8_reg8, rA,rB,rC,dstreg,srcreg  @rA,rB are free registers
	ldrb \rA,[cpuregs,\dstreg]
	ldrb \rB,[cpuregs,\srcreg]
	mov \rC,\rA					@rC holds the pre-op value of rA
	add \rA,\rB					@rA holds the post-op value
	tst cpuflags,cflag_set
	it eq
	addeq \rA,1
	strb \rA,[cpuregs,\dstreg]
	tst \rA,0x100				@cflag
	set_c_eq
	tst \rA,0xff				@zflag
	set_z_eq
	and \rC,0xf					@hflag
	and \rB,0xf
	add \rC,\rB
	tst \rC, 0x10
	set_h_eq
	clear_nflag
.endm

@Writing specific instructions for adding reg A to reg A saves space
.macro add_regA_regA, rA    @rA is a free register
	ldrb \rA,[cpuregs,A_reg]
	lsl \rA,2   @rA holds the post-op val
	strb \rA,[cpuregs,A_reg]
	tst \rA,0x100				@cflag
	set_c_eq
	tst \rA,0xff				@zflag
	set_z_eq
	tst \rA, 0x10				@hflag
	set_h_eq
	clear_nflag
.endm

.macro adc_regA_regA, rA    @rA is a free reg
	ldrb \rA,[cpuregs,A_reg]
	lsl \rA,2   @rA holds the post-op val
	tst cpuflags,cflag_set
	it eq
	addeq \rA,1
	strb \rA,[cpuregs,A_reg]
	tst \rA,0x100				@cflag
	set_c_eq
	tst \rA,0xff				@zflag
	set_z_eq
	tst \rA, 0x10				@hflag
	set_h_eq
	clear_nflag
.endm

.macro sub_A_reg8, rA,rB,rC,regname @rA,rB,rC are free registers, regname is reg being subtracted from A
	ldrb \rA,[cpuregs,A_reg]
	ldrb \rB,[cpuregs,\regname]
	mov \rC,\rA
	subs \rA,\rB
	strb \rA,[cpuregs,A_reg]
	set_z_eq
	ite mi							@if the result is negative, this will be true (a borrow happened)
	andmi cpuflags,cflag_clear		@the cflag is cleared if a borrow occurred
	orrpl cpuflags,cflag_set		@the cflag is set if a borrow did not occur	
	and \rC,0xf						@hflag
	and \rB,0xf
	cmp \rC,\rB
	ite mi
	andmi cpuflags,hflag_clear
	orrpl cpuflags,hflag_set
	set_nflag
.endm

.macro sbc_A_reg8, rA,rB,rC,regname @rA,rB,rC are free registers, regname is reg being subtracted from A
	ldrb \rA,[cpuregs,A_reg]
	ldrb \rB,[cpuregs,\regname]
	mov \rC,\rA
	tst cpuflags,cflag_set
	it eq
	subeq \rA,1
	subs \rA,\rB							@do this subtraction last so I can use it to set flags
	strb \rA,[cpuregs,A_reg]
	set_z_eq
	ite mi									@if the result is negative, this will be true (a borrow happened)
	andmi cpuflags,cflag_clear				@the cflag is cleared if a borrow occurred
	orrpl cpuflags,cflag_set				@the cflag is set if a borrow did not occur
	and \rC,\rC,0xf							@hflag
	and \rB,\rB,0xf
	cmp \rC,\rB
	ite mi
	andmi cpuflags,hflag_clear
	orrpl cpuflags,hflag_set
	set_nflag
.endm

.macro and_A_reg8, rA,rB,regname @rA,rB are free registers
	ldrb \rA,[cpuregs,A_reg]
	ldrb \rB,[cpuregs,\regname]
	ands \rB,\rA,\rB
	strb \rB,[cpuregs,A_reg]
	ite eq
	moveq cpuregs,0xa0    @Z,H = 1; N,C = 0
	movne cpuregs,0x20	  @H = 1; Z,N,C = 0
.endm

.macro add_hl_r16, offset, rA, rB, rC
	ldrh \rA,[cpuregs,HL_reg]
	ldrh \rB,[cpuregs,\offset]
	@Im not doing the h flag right now
	adds \rC,\rA,\rB

.endm
