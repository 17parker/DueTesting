.syntax unified


#define debug_bkpts				@ this puts bkpt in get_op
@#define debug_mem_catch			@ this jumps exection to routine before continuing execution (not implemented)
@#define debug_ld_A_rr				@ this puts known value into sc4 when exiting ld_A_rr
@#define debug_ld_ra16_d8			@ this puts known value into sc4 when exiting ld_ra16_d8


@ this needs to be in this file for the preprocessor directives to work, I think?
#ifdef debug_bkpts
.macro get_op
	ldrb gbc_op,[progc],1
	bkpt 22
	ldr pc,[xlbl_addr,gbc_op,lsl 2]
.endm
#else 
.macro get_op
	ldrb gbc_op,[progc],1
	ldr pc,[xlbl_addr,gbc_op,lsl 2]
.endm
#endif

.include "src/gbc_funcs.inc"

IER_write:
	get_op

IO_write:
	get_op

IER_read:
	get_op

IO_read:
	get_op

OAM_write:
	get_op

OAM_read:
	get_op

.macro ld_A_rr offset, rA, rB
#ifdef debug_ld_A_rr
	mov sc4,0xff
#else
#endif

.endm

.macro ld_ra16_d8 offset, data, rA, rB @load into (ra16) the data d8
#ifdef debug_ld_ra16_d8
	mov sc4,0xff
#endif
	ldrh \rA,[cpuregs,\offset] @rA holds the 16-bit address
	add \rB,\rA,1
	tst \rB,0x10000			@check for IER
	bne IER_write\@
	subs \rB,\rA,0xFE00		@check if in lower memory space
	blt lower\@					@pass rA to lower
	subs \rA,\rB,0x100		@check if in OAM
	blt OAM_write\@				@pass RB to OAM
	subs \rB,\rA,0x80		@check if in IO
	blt IO_write\@				@pass RA to IO
	ldr \rB,=hram			@it is in HRAM
#ifdef debug_mem_catch
	mov sc4,0
	b exit_ra16_d8\@
#else
	strb \data,[\rB,\rA]	@store RB in HRAM
	get_op
#endif

IER_write\@:
	@\data has value writing to IER
#ifdef debug_mem_catch
	mov sc4,0x1
	b exit_ra16_d8\@
#else
	get_op
#endif


OAM_write\@:
	@\rB has low 8 bits of address
#ifdef debug_mem_catch
	mov sc4,0x2
	b exit_ra16_d8\@
#else
	get_op
#endif


IO_write\@:
	@\rB has low 8 bits of address
#ifdef debug_mem_catch
	mov sc4,0x3
	b exit_ra16_d8\@
#else
	get_op
#endif

lower\@: @\rA holds the 16-bit address
	subs \rB,\rA,0x8000				@check if in cart
#ifdef debug_mem_catch
	mov sc4,0x4
	blt exit_ra16_d8\@
#else
	ittt lt
	strblt \data,[cartaddr,\rA]
	get_oplt
#endif
	subs \rA,\rB,0x2000				@check if in vram
#ifdef debug_mem_catch
	mov sc4,0x5
	blt exit_ra16_d8\@
#else
	itttt lt
	ldrlt \rA,=vramn
	strblt \data,[\rA,\rB]
	get_oplt
#endif
	subs \rB,\rA,0x2000				@check if in extram
#ifdef debug_mem_catch
	mov sc4,0x6
	blt exit_ra16_d8\@
#else
	itttt lt
	ldrlt \rB,=extram
	strblt \data,[\rB,\rA]
	get_oplt
#endif
	subs \rA,\rB,0x1000				@check if in wram0
#ifdef debug_mem_catch
	mov sc4,0x7
	blt exit_ra16_d8\@
#else
	itttt lt
	ldrlt \rA,=wram0
	strblt \data,[\rA,\rB]
	get_oplt
#endif
#ifdef debug_mem_catch				
	mov sc4,0x8						@it is in wramn
	b exit_ra16_d8\@
#else
	ldr \rB,=wramn
	strb \data,[\rB,\rA]			@the last get_op is outside the macro so the breakpoint in get_op is hit
#endif
#ifdef debug_mem_catch
exit_ra16_d8\@:
#endif
.endm

.macro ld_rr_nn cpu_offset,rdata @load into 16-bit register rr the immediate data
	strh \rdata,[cpuregs,\cpu_offset]
.endm


.bss
oam: .space 160,0
io: .space 128,0
hram: .space 127,0
ier: .byte 0
.align 4
mem_map: 
wram0: .space 0x1000
vram0: .space 0x2000
vram1: .space 0x2000 
wram1: .space 0x1000 
extram: .word =0x6100a000
vramn: .word vram0
wramn: .word wram1
wram2: .space 0x1000
wram3: .space 0x1000
wram4: .space 0x1000
wram5: .space 0x1000
wram6: .space 0x1000
wram7: .space 0x1000
@pixels: .space 46080


cpu_regs_addr: .space 20
@NOTE: because my CPU flags are in a register, the F register here is never updated
@C B BC E D DE L H HL F A AF  WRAM0_addr WRAMn_addr VRAMn_addr scratch_reg
@Reg order:
@0 1 0  2 3 2  4 5 4  6 7 6   8          12			16		   20


.data

.text

.align 4
cart_read:
	get_op

.align 4
cart_write:
	get_op

.align 4
vram_read:
	get_op

.align 4
vram_write:
	get_op

.align 4
extram_read:
	get_op

.align 4
extram_write:
	get_op

.align 4
wram0_read:
	get_op

.align 4
wram0_write:
	get_op

.align 4
wramn_read:
	get_op

.align 4
wramn_write:
	get_op

.align 4
echo_read:
	get_op

.align 4
echo_write:
	get_op

.align 4
ier_read:
	get_op

.align 4
ier_write:
	get_op

.align 4
oam_read:
	get_op

.align 4
oam_write:
	get_op

.align 4
io_read:
	get_op

.align 4
io_write:
	get_op

.align 4
hlram_read:
	get_op

.align 4
hlram_write:
	get_op


.align 4
wrambanks:
	.word wram0
	.word wram1
	.word wram2
	.word wram3
	.word wram4
	.word wram5
	.word wram6
	.word wram7
vrambanks:
	.word vram0
	.word vram1

.align 4
lower_mem_catch_routines:
lower_mem_catch_read_routines:
	.word cart_read + 1
	.word cart_read + 1
	.word cart_read + 1
	.word cart_read + 1
	.word cart_read + 1
	.word cart_read + 1
	.word cart_read + 1
	.word cart_read + 1
	.word vram_read + 1
	.word vram_read + 1
	.word extram_read + 1
	.word extram_read + 1
	.word wram0_read + 1
	.word wramn_read + 1
	.word echo_read + 1
	.word echo_read + 1
	.word ier_read + 1

.align 4
lower_mem_catch_write_routines:
	.word cart_write + 1
	.word cart_write + 1
	.word cart_write + 1
	.word cart_write + 1
	.word cart_write + 1
	.word cart_write + 1
	.word cart_write + 1
	.word cart_write + 1
	.word vram_write + 1
	.word vram_write + 1
	.word extram_write + 1
	.word extram_write + 1
	.word wram0_write + 1
	.word wramn_write + 1
	.word echo_write + 1
	.word echo_write + 1
	.word ier_write + 1

.align 4
upper_mem_catch_routines:
upper_mem_catch_read_routines:
	.word oam_read + 1
	.word oam_read + 1
	.word io_read + 1
	.word hlram_read + 1

.align 4
upper_mem_catch_write_routines:
	.word oam_write + 1
	.word oam_write + 1
	.word io_write + 1
	.word hlram_write + 1
	

.align 4
x_lbl:
    .word x00+1
    .word x01+1
    .word x02+1
    .word x03+1
    .word x04+1
    .word x05+1
    .word x06+1
    .word x07+1
    .word x08+1
    .word x09+1
    .word x0a+1
    .word x0b+1
    .word x0c+1
    .word x0d+1
    .word x0e+1
    .word x0f+1
    .word x10+1
    .word x11+1
    .word x12+1
    .word x13+1
    .word x14+1
    .word x15+1
    .word x16+1
    .word x17+1
    .word x18+1
    .word x19+1
    .word x1a+1
    .word x1b+1
    .word x1c+1
    .word x1d+1
    .word x1e+1
    .word x1f+1
    .word x20+1
    .word x21+1
    .word x22+1
    .word x23+1
    .word x24+1
    .word x25+1
    .word x26+1
    .word x27+1
    .word x28+1
    .word x29+1
    .word x2a+1
    .word x2b+1
    .word x2c+1
    .word x2d+1
    .word x2e+1
    .word x2f+1
    .word x30+1
    .word x31+1
    .word x32+1
    .word x33+1
    .word x34+1
    .word x35+1
    .word x36+1
    .word x37+1
    .word x38+1
    .word x39+1
    .word x3a+1
    .word x3b+1
    .word x3c+1
    .word x3d+1
    .word x3e+1
    .word x3f+1
    .word x40+1
    .word x41+1
    .word x42+1
    .word x43+1
    .word x44+1
    .word x45+1
    .word x46+1
    .word x47+1
    .word x48+1
    .word x49+1
    .word x4a+1
    .word x4b+1
    .word x4c+1
    .word x4d+1
    .word x4e+1
    .word x4f+1
    .word x50+1
    .word x51+1
    .word x52+1
    .word x53+1
    .word x54+1
    .word x55+1
    .word x56+1
    .word x57+1
    .word x58+1
    .word x59+1
    .word x5a+1
    .word x5b+1
    .word x5c+1
    .word x5d+1
    .word x5e+1
    .word x5f+1
    .word x60+1
    .word x61+1
    .word x62+1
    .word x63+1
    .word x64+1
    .word x65+1
    .word x66+1
    .word x67+1
    .word x68+1
    .word x69+1
    .word x6a+1
    .word x6b+1
    .word x6c+1
    .word x6d+1
    .word x6e+1
    .word x6f+1
    .word x70+1
    .word x71+1
    .word x72+1
    .word x73+1
    .word x74+1
    .word x75+1
    .word x76+1
    .word x77+1
    .word x78+1
    .word x79+1
    .word x7a+1
    .word x7b+1
    .word x7c+1
    .word x7d+1
    .word x7e+1
    .word x7f+1
    .word x80+1
    .word x81+1
    .word x82+1
    .word x83+1
    .word x84+1
    .word x85+1
    .word x86+1
    .word x87+1
    .word x88+1
    .word x89+1
    .word x8a+1
    .word x8b+1
    .word x8c+1
    .word x8d+1
    .word x8e+1
    .word x8f+1
    .word x90+1
    .word x91+1
    .word x92+1
    .word x93+1
    .word x94+1
    .word x95+1
    .word x96+1
    .word x97+1
    .word x98+1
    .word x99+1
    .word x9a+1
    .word x9b+1
    .word x9c+1
    .word x9d+1
    .word x9e+1
    .word x9f+1
    .word xa0+1
    .word xa1+1
    .word xa2+1
    .word xa3+1
    .word xa4+1
    .word xa5+1
    .word xa6+1
    .word xa7+1
    .word xa8+1
    .word xa9+1
    .word xaa+1
    .word xab+1
    .word xac+1
    .word xad+1
    .word xae+1
    .word xaf+1
    .word xb0+1
    .word xb1+1
    .word xb2+1
    .word xb3+1
    .word xb4+1
    .word xb5+1
    .word xb6+1
    .word xb7+1
    .word xb8+1
    .word xb9+1
    .word xba+1
    .word xbb+1
    .word xbc+1
    .word xbd+1
    .word xbe+1
    .word xbf+1
    .word xc0+1
    .word xc1+1
    .word xc2+1
    .word xc3+1
    .word xc4+1
    .word xc5+1
    .word xc6+1
    .word xc7+1
    .word xc8+1
    .word xc9+1
    .word xca+1
    .word xcb+1
    .word xcc+1
    .word xcd+1
    .word xce+1
    .word xcf+1
    .word xd0+1
    .word xd1+1
    .word xd2+1
    .word xd3+1
    .word xd4+1
    .word xd5+1
    .word xd6+1
    .word xd7+1
    .word xd8+1
    .word xd9+1
    .word xda+1
    .word xdb+1
    .word xdc+1
    .word xdd+1
    .word xde+1
    .word xdf+1
    .word xe0+1
    .word xe1+1
    .word xe2+1
    .word xe3+1
    .word xe4+1
    .word xe5+1
    .word xe6+1
    .word xe7+1
    .word xe8+1
    .word xe9+1
    .word xea+1
    .word xeb+1
    .word xec+1
    .word xed+1
    .word xee+1
    .word xef+1
    .word xf0+1
    .word xf1+1
    .word xf2+1
    .word xf3+1
    .word xf4+1
    .word xf5+1
    .word xf6+1
    .word xf7+1
    .word xf8+1
    .word xf9+1
    .word xfa+1
    .word xfb+1
    .word xfc+1
    .word xfd+1
    .word xfe+1
    .word xff+1


.align 4
cb_lbl:
	.word cb00+1
	.word cb01+1
	.word cb02+1
	.word cb03+1
	.word cb04+1
	.word cb05+1
	.word cb06+1
	.word cb07+1
	.word cb08+1
	.word cb09+1
	.word cb0a+1
	.word cb0b+1
	.word cb0c+1
	.word cb0d+1
	.word cb0e+1
	.word cb0f+1
	.word cb10+1
	.word cb11+1
	.word cb12+1
	.word cb13+1
	.word cb14+1
	.word cb15+1
	.word cb16+1
	.word cb17+1
	.word cb18+1
	.word cb19+1
	.word cb1a+1
	.word cb1b+1
	.word cb1c+1
	.word cb1d+1
	.word cb1e+1
	.word cb1f+1
	.word cb20+1
	.word cb21+1
	.word cb22+1
	.word cb23+1
	.word cb24+1
	.word cb25+1
	.word cb26+1
	.word cb27+1
	.word cb28+1
	.word cb29+1
	.word cb2a+1
	.word cb2b+1
	.word cb2c+1
	.word cb2d+1
	.word cb2e+1
	.word cb2f+1
	.word cb30+1
	.word cb31+1
	.word cb32+1
	.word cb33+1
	.word cb34+1
	.word cb35+1
	.word cb36+1
	.word cb37+1
	.word cb38+1
	.word cb39+1
	.word cb3a+1
	.word cb3b+1
	.word cb3c+1
	.word cb3d+1
	.word cb3e+1
	.word cb3f+1
	.word cb40+1
	.word cb41+1
	.word cb42+1
	.word cb43+1
	.word cb44+1
	.word cb45+1
	.word cb46+1
	.word cb47+1
	.word cb48+1
	.word cb49+1
	.word cb4a+1
	.word cb4b+1
	.word cb4c+1
	.word cb4d+1
	.word cb4e+1
	.word cb4f+1
	.word cb50+1
	.word cb51+1
	.word cb52+1
	.word cb53+1
	.word cb54+1
	.word cb55+1
	.word cb56+1
	.word cb57+1
	.word cb58+1
	.word cb59+1
	.word cb5a+1
	.word cb5b+1
	.word cb5c+1
	.word cb5d+1
	.word cb5e+1
	.word cb5f+1
	.word cb60+1
	.word cb61+1
	.word cb62+1
	.word cb63+1
	.word cb64+1
	.word cb65+1
	.word cb66+1
	.word cb67+1
	.word cb68+1
	.word cb69+1
	.word cb6a+1
	.word cb6b+1
	.word cb6c+1
	.word cb6d+1
	.word cb6e+1
	.word cb6f+1
	.word cb70+1
	.word cb71+1
	.word cb72+1
	.word cb73+1
	.word cb74+1
	.word cb75+1
	.word cb76+1
	.word cb77+1
	.word cb78+1
	.word cb79+1
	.word cb7a+1
	.word cb7b+1
	.word cb7c+1
	.word cb7d+1
	.word cb7e+1
	.word cb7f+1
	.word cb80+1
	.word cb81+1
	.word cb82+1
	.word cb83+1
	.word cb84+1
	.word cb85+1
	.word cb86+1
	.word cb87+1
	.word cb88+1
	.word cb89+1
	.word cb8a+1
	.word cb8b+1
	.word cb8c+1
	.word cb8d+1
	.word cb8e+1
	.word cb8f+1
	.word cb90+1
	.word cb91+1
	.word cb92+1
	.word cb93+1
	.word cb94+1
	.word cb95+1
	.word cb96+1
	.word cb97+1
	.word cb98+1
	.word cb99+1
	.word cb9a+1
	.word cb9b+1
	.word cb9c+1
	.word cb9d+1
	.word cb9e+1
	.word cb9f+1
	.word cba0+1
	.word cba1+1
	.word cba2+1
	.word cba3+1
	.word cba4+1
	.word cba5+1
	.word cba6+1
	.word cba7+1
	.word cba8+1
	.word cba9+1
	.word cbaa+1
	.word cbab+1
	.word cbac+1
	.word cbad+1
	.word cbae+1
	.word cbaf+1
	.word cbb0+1
	.word cbb1+1
	.word cbb2+1
	.word cbb3+1
	.word cbb4+1
	.word cbb5+1
	.word cbb6+1
	.word cbb7+1
	.word cbb8+1
	.word cbb9+1
	.word cbba+1
	.word cbbb+1
	.word cbbc+1
	.word cbbd+1
	.word cbbe+1
	.word cbbf+1
	.word cbc0+1
	.word cbc1+1
	.word cbc2+1
	.word cbc3+1
	.word cbc4+1
	.word cbc5+1
	.word cbc6+1
	.word cbc7+1
	.word cbc8+1
	.word cbc9+1
	.word cbca+1
	.word cbcb+1
	.word cbcc+1
	.word cbcd+1
	.word cbce+1
	.word cbcf+1
	.word cbd0+1
	.word cbd1+1
	.word cbd2+1
	.word cbd3+1
	.word cbd4+1
	.word cbd5+1
	.word cbd6+1
	.word cbd7+1
	.word cbd8+1
	.word cbd9+1
	.word cbda+1
	.word cbdb+1
	.word cbdc+1
	.word cbdd+1
	.word cbde+1
	.word cbdf+1
	.word cbe0+1
	.word cbe1+1
	.word cbe2+1
	.word cbe3+1
	.word cbe4+1
	.word cbe5+1
	.word cbe6+1
	.word cbe7+1
	.word cbe8+1
	.word cbe9+1
	.word cbea+1
	.word cbeb+1
	.word cbec+1
	.word cbed+1
	.word cbee+1
	.word cbef+1
	.word cbf0+1
	.word cbf1+1
	.word cbf2+1
	.word cbf3+1
	.word cbf4+1
	.word cbf5+1
	.word cbf6+1
	.word cbf7+1
	.word cbf8+1
	.word cbf9+1
	.word cbfa+1
	.word cbfb+1
	.word cbfc+1
	.word cbfd+1
	.word cbfe+1
	.word cbff+1


@OPTIMIZATIONS:
@For operations that load CPU registers, if the registers are adjacent, I can do one ldrh instead of two ldrb
@Ldr/strs are 1 cycle faster if they are staggered
@In some cases, its faster to clear all cpu flags at once and OR them if necesssary (the final flag check will just be an it instead of ite)

@Does anything special happen when H/L are written to

@Resources:
@https://web.eecs.umich.edu/~prabal/teaching/eecsc373-f10/readings/ARMv7-M_ARM.pdf
@https://stackoverflow.com/questions/24115899/arm-ldr-instruction-on-pc-register

@Half-Carry flag:
https://robdor.com/2016/08/10/gameboy-emulator-half-carry-flag/

.global gbc

.align 4
gbc:
	mov sc0,0							@r0 - working reg
	ldr progc,=0x60000100				@r1 - pc
	ldr stackptr,=wram0					@r2 - stack pointer
	ldr cpuregs,=cpu_regs_addr			@r3 - cpu registers address
	mov args,0							@r4 - holds the arguments for opcodes, if they have any
	mov sc1,0							@r5 - working reg
	mov gbc_op,0						@r6 - holds current OP
	mov cpuflags,0						@r7 - cpu flags: 0bZNHCxxxx
	mov sc2,0							@r8 - working reg
	mov sc3,0							@r9 - working reg
	ldr cartaddr,=0x60000000			@r10 - holds cartridge base address
	ldr xlbl_addr,=x_lbl				@r11 - holds x jump table base address
	mov sc4,0							@r12 - working reg

	ldr r0,=vram0
	str r0,[cpuregs,vramn_reg]
	ldr r0,=wram0
	str r0,[cpuregs,wram0_reg]
	ldr r0,=wram1
	str r0,[cpuregs,wramn_reg]

	mov r0,0	@reset the system
	strh r0,[cpuregs,AF_reg]
	strh r0,[cpuregs,BC_reg]
	strh r0,[cpuregs,DE_reg]
	strh r0,[cpuregs,HL_reg]
	ldr r0,=io	@To be consistent with the memory viewer
	mov r8,0x91
	strb r8,[r0,0x40]
	mov r8,0x81
	strb r8,[r0,0x41]
	mov r8,0x80
	strb r8,[cpuregs,F_reg]
	bkpt 50
	get_op

.align 4
x00: @NOP
	get_op
.align 4
x01: @LD BC,d16 - no flags
	get_2_arg
	ld_rr_nn BC_reg,args
	get_op

.align 4
x02: @LD (BC),A - Load to the absolute address (BC), data from the 8-bit A register
	ldrb sc0,[cpuregs,A_reg]  @sc0 holds the data from A_reg
	ld_ra16_d8 BC_reg, sc0,sc1,sc2
	get_op


.align 4
x03: @INC BC - no flags
	inc_reg16 sc0,BC_reg
	get_op

.ltorg

.align 4
x04: @INC B - z if result is 0, N is reset, H if carry from bit 3
	inc_reg8 sc0,B_reg
	get_op

.align 4
x05: @DEC B - z if result is 0, N is set, H is set if borrow from bit 4
	dec_reg8 sc0,B_reg
	get_op

.align 4
x06: @LD B,d8
	get_1_arg
	ld_reg8_d8 B_reg
	get_op

.align 4
x07: @RLCA - Rotate A left, old bit 7 to bit 0 and carry. Z, N, H cleared
	ldrb sc0,[cpuregs,A_reg] @sc0 holds register A
	tst sc0,0x80
	lsl sc0,1
	eor cpuflags,cpuflags		 @clear all flags, set c as necessary
	itt ne
	orrne sc0,1
	orrne cpuflags,cflag_set
	strb sc0,[cpuregs,A_reg]
	get_op

.align 4
x08: @LD (nn),SP - load to the absolute address specified by the 16-bit operand nn, data from the 16-bit SP register
	get_2_arg
	get_op

.align 4
x09: @ADD HL,BC - z ignored, n cleared, h, c conditionally set.
	get_op

.align 4
x0a: @LD A,(BC) - Load to the accumulator, data from the address specified by (BC)
	ld_A_rr BC_reg,sc0
	get_op

.align 4
x0b: @DEC BC - no flags
	dec_reg16 sc0,BC_reg
	get_op

.align 4
x0c: @INC C
	inc_reg8 sc0,C_reg
	get_op

.align 4
x0d: @DEC C
	dec_reg8 sc0,C_reg
	get_op

.align 4
x0e: @LD C,d8 - no flags
	get_1_arg
	ld_reg8_d8 C_reg
	get_op

.align 4
x0f: @RRCA

.align 4
x10: @STOP 0 - clock, oscillator, lcd controller are stopped, cancelled by reset signal
	bkpt 99
stoplbl:
	b stoplbl

.align 4
x11: @LD DE, d16
	get_2_arg		
	ld_rr_nn DE_reg,args
	get_op
 
.align 4
x12: @LD (DE),A
	ldrb sc0,[cpuregs,A_reg]
	ld_ra16_d8 DE_reg, sc0,sc1,sc2
	get_op
	 
.align 4
x13: @INC DE
	inc_reg16 sc0, DE_reg
	get_op
	 
.align 4
x14: @INC D
	inc_reg8 sc0,D_reg
	get_op
	 
.align 4
x15: @DEC D
	dec_reg8 sc0,D_reg
	get_op
	 
.align 4
x16: @LD D,d8
	get_1_arg
	ld_reg8_d8 D_reg
	get_op
	 
.align 4
x17: @RLA
	 
.align 4
x18: @JR r8
	 
.align 4
x19: @ADD HL,DE
	 
.align 4
x1a: @LD A,(DE)
	 
.align 4
x1b: @DEC DE
	dec_reg16 sc0,DE_reg
	get_op
	 
.align 4
x1c: @INC E
	inc_reg8 sc0,E_reg
	get_op

.align 4
x1d: @DEC E
	dec_reg8 sc0,E_reg
	get_op
	 
.align 4
x1e: @LD E,d8
	get_1_arg
	ld_reg8_d8 E_reg
	get_op
	 
.align 4
x1f: @RRA


.align 4
x20: @JR NZ,s8 - jump to (PC + s8) if Zero flag is reset - s8 is SIGNED
	get_1_arg_signed
	tst cpuflags,zflag_set
	it eq
	addeq progc,progc,args
	get_op

.align 4
x21: @LD HL,d16 - no flags
	get_2_arg
	ld_rr_nn HL_reg,args
	get_op

.align 4
x22: @LD (HL+),A - Same as LD (HL),A - INC HL
	ldrh sc2,[cpuregs,HL_reg]
	strh sc2,[cpuregs,SC_reg] @use a different register for small optimization
	add sc2,1
	strh sc2,[cpuregs,HL_reg]
	ldrb sc0,[cpuregs,A_reg]
	ld_ra16_d8 SC_reg,sc0,sc1,sc2
	get_op
   
.align 4
x23: @INC HL
	inc_reg16 sc0,HL_reg
	get_op
	 
.align 4
x24: @INC H
	inc_reg8 sc0,H_reg
	get_op
	 
.align 4
x25: @DEC H
	dec_reg8 sc0,H_reg
	get_op
	 
.align 4
x26: @LD H,d8
	get_1_arg
	ld_reg8_d8 H_reg
	get_op
	 
.align 4
x27: @DAA
	 
.align 4
x28: @JR Z,r8

	 
.align 4
x29: @ADD HL,HL


.align 4
x2a: @LD A,(HL+)

	 
.align 4
x2b: @DEC HL
	dec_reg16 r0,HL_reg
	get_op
	 
.align 4
x2c: @INC L
	inc_reg8 sc0,L_reg
	get_op
	 
.align 4
x2d: @DEC L
	dec_reg8 sc0,L_reg
	get_op
	 
.align 4
x2e: @LD L,d8
	get_1_arg
	ld_reg8_d8 L_reg
	get_op
	 
t1:
	.word 45
t2:
	.word 30
.align 4
x2f: @CPL - USED FOR TIMING TESTS
	nop
	bkpt 100
	nop
	ldr sc1,=x2e
	ldr sc1,=x2e
	ldr sc1,=x2e
	ldr sc1,=x2e
	strh sc3,[cpuregs,HL_reg]
	strh sc3,[cpuregs,HL_reg]
	strh sc3,[cpuregs,HL_reg]
	strh sc3,[cpuregs,HL_reg]
	ldr sc1,=x2e
	strh sc3,[cpuregs,HL_reg]
	ldr sc1,=x2e
	strh sc3,[cpuregs,HL_reg]
	ldr sc1,=x2e
	strh sc3,[cpuregs,HL_reg]
	ldr sc1,=x2e
	strh sc3,[cpuregs,HL_reg]
	ldr sc1,=x2e
	strh sc3,[cpuregs,HL_reg]
	mov sc3,0xab
	mov sc4,0xcd
	ubfx sc3,sc3,5,3
	ubfx sc4,sc4,2,3
	adds sc3,sc4
	adds sc3,sc4
	adds sc3,sc4
	adds sc3,sc4
	adds sc3,sc4
	adds sc3,sc3,sc4, lsl 2
	adds sc3,sc3,sc4, lsl 2
	adds sc3,sc3,sc4, lsl 2
	adds sc3,sc3,sc4, lsl 2
	adds sc3,sc3,sc4, lsl 31
	adds sc3,sc4
	adds sc3,sc4
	adds sc3,sc4
	ittee mi
	ldrmi sc1,=t1
	ldrmi sc1,=t1
	ldrpl sc1,=t2
	ldrpl sc1,=t2
	bkpt 101
	 
.align 4
x30: @JR NC,r8

	 
.align 4
x31: @LD sp,d16 - load immediate into stack pointer
	@This needs a mem catch - I cant really assume the stack is going to be in WRAM0
	get_2_arg
	sub args,0xc000 @need to subtract c000 because GBC I need the offset into wram
	cmp args,0x1000
	it mi
	addmi stackptr,sc0,cartaddr
   	get_op	

.align 4
x32: @LD (HL-),A
	ldrh sc0,[cpuregs,HL_reg]
	strh sc0,[cpuregs,SC_reg] @use a different register for small optimization
	sub sc0,1
	strh sc0,[cpuregs,HL_reg]
	ldrb sc0,[cpuregs,A_reg]
	ld_ra16_d8 SC_reg,sc0,sc1,sc2
	get_op
	 
.align 4
x33: @INC SP

	 
.align 4
x34: @INC (HL)

	 
.align 4
x35: @DEC (HL)

	 
.align 4
x36: @LD (HL),d8
	get_1_arg
	mov sc2,args			  @sc2 holds the data
	ldrh sc1,[cpuregs,HL_reg] @sc1 holds the 16-bit address
	add sc0,sc1,1			  @sc0 holds (16-bit addr + 1)
	tst sc0,0x10000			  @check for IER
	bne IER_write36
	mov sc0,0xfe00
	subs sc0,sc1,sc0		  @check if in lower memory space
	bmi lower36					  @pass rA to lower
	mov sc1,0x100
	subs sc1,sc0,sc1		  @check if in OAM
	bmi OAM_write36				  @pass RB to OAM
	subs sc0,sc1,0x80		  @check if in IO
	bmi IO_write36				  @pass RA to IO
	ldr sc0,=hram			  @it is in HRAM
	strb sc2,[sc0,sc1]		  @store RB in HRAM
	get_op

IER_write36:
	@sc2 has value writing to IER
	get_op

OAM_write36:
	@sc0 has low 8 bits of address
	get_op

IO_write36:
	@sc0 has low 8 bits of address
	get_op

lower36: @sc1 holds the 16-bit address
	mov sc0,0x8000
	subs sc0,sc1,sc0				@check if in cart
	ittt mi
	strbmi sc2,[cartaddr,sc1]
	get_opmi
	mov sc1,0x2000
	subs sc1,sc0,sc1				@check if in vram
	itttt mi
	ldrmi sc1,=vramn
	strbmi sc2,[sc1,sc0]
	get_opmi
	mov sc0,0x2000
	subs sc0,sc1,sc0				@check if in extram
	itttt mi
	ldrmi sc0,=extram
	strbmi sc2,[sc0,sc1]
	get_opmi
	mov sc1,0x1000
	subs sc1,sc0,sc1				@check if in wram0
	itttt mi
	ldrmi sc1,=wram0
	strbmi sc2,[sc1,sc0]
	get_opmi
	ldr sc0,=wramn					@it is in wramn
	strb sc2,[sc0,sc1]				@the last get_op is outside the macro so the breakpoint in get_op is hit
	get_op

.align 4
x37: @SCF
	 
.align 4
x38: @JR C,r8

	 
.align 4
x39: @ADD HL,SP

	 
.align 4
x3a: @LD A,(HL-)

.ltorg
	 
.align 4
x3b: @DEC SP

	 
.align 4
x3c: @INC A
	inc_reg8 sc0,A_reg
	get_op

.align 4
x3d: @DEC A
	dec_reg8 sc0,A_reg
	get_op
	 
.align 4
x3e: @LD A,d8 - No flags affected 
	get_1_arg
	ld_reg8_d8 A_reg
	get_op
	 
.align 4
x3f: @CCF
	 
.align 4
x40: @LD B,B
	get_op
	 
.align 4
x41: @LD B,C
	ld_reg8_reg8 sc0,B_reg,C_reg
	get_op
	 
.align 4
x42: @LD B,D
	ld_reg8_reg8 sc0,B_reg,D_reg
	get_op
	 
.align 4
x43: @LD B,E
	ld_reg8_reg8 sc0,B_reg,E_reg
	get_op
	 
.align 4
x44: @LD B,H
	ld_reg8_reg8 sc0,B_reg,H_reg
	get_op
	 
.align 4
x45: @LD B,L
	ld_reg8_reg8 sc0,B_reg,L_reg
	get_op
	 
.align 4
x46: @LD B,(HL)
	get_op
	 
.align 4
x47: @LD B,A
	ld_reg8_reg8 sc0,B_reg,A_reg
	get_op
	 
.align 4
x48: @LD C,B
	ld_reg8_reg8 sc0,C_reg,B_reg
	get_op
	 
.align 4
x49: @LD C,C
	get_op
	 
.align 4
x4a: @LD C,D
	ld_reg8_reg8 sc0,C_reg,D_reg
	get_op
	 
.align 4
x4b: @LD C,E
	ld_reg8_reg8 sc0,C_reg,E_reg
	get_op
	 
.align 4
x4c: @LD C,H
	ld_reg8_reg8 sc0,C_reg,H_reg
	get_op
	 
.align 4
x4d: @LD C,L
	ld_reg8_reg8 sc0,C_reg,L_reg
	get_op
	 
.align 4
x4e: @LD C,(HL)

	 
.align 4
x4f: @LD C,A
	ld_reg8_reg8 sc0,C_reg,A_reg
	get_op
	 
.align 4
x50: @LD D,B
	ld_reg8_reg8 sc0,D_reg,B_reg
	get_op
	 
.align 4
x51: @LD D,C
	ld_reg8_reg8 sc0,D_reg,C_reg
	get_op
	 
.align 4
x52: @LD D,D
	get_op
	 
.align 4
x53: @LD D,E
	ld_reg8_reg8 sc0,D_reg,E_reg
	get_op
	 
.align 4
x54: @LD D,H
	ld_reg8_reg8 sc0,D_reg,H_reg
	get_op
	 
.align 4
x55: @LD D,L
	ld_reg8_reg8 sc0,D_reg,L_reg
	get_op
	 
.align 4
x56: @LD D,(HL)

	 
.align 4
x57: @LD D,A
	ld_reg8_reg8 sc0,D_reg,A_reg
	get_op
	 
.align 4
x58: @LD E,B
	ld_reg8_reg8 sc0,E_reg,B_reg
	get_op
	 
.align 4
x59: @LD E,C
	ld_reg8_reg8 sc0,E_reg,C_reg
	get_op
	 
.align 4
x5a: @LD E,D
	ld_reg8_reg8 sc0,E_reg,D_reg
	get_op
	 
.align 4
x5b: @LD E,E
	get_op
	 
.align 4
x5c: @LD E,H
	ld_reg8_reg8 sc0,E_reg,H_reg
	get_op
	 
.align 4
x5d: @LD E,L
	ld_reg8_reg8 sc0,E_reg,L_reg
	get_op
	 
.align 4
x5e: @LD E,(HL)

	 
.align 4
x5f: @LD E,A
	ld_reg8_reg8 sc0,E_reg,A_reg
	get_op
	 
.align 4
x60: @LD H,B
	ld_reg8_reg8 sc0,H_reg,B_reg
	get_op
	 
.align 4
x61: @LD H,C
	ld_reg8_reg8 sc0,H_reg,C_reg
	get_op
	 
.align 4
x62: @LD H,D
	ld_reg8_reg8 sc0,H_reg,D_reg
	get_op
	 
.align 4
x63: @LD H,E
	ld_reg8_reg8 sc0,H_reg,E_reg
	get_op
	 
.align 4
x64: @LD H,H
	get_op
	 
.align 4
x65: @LD H,L
	ld_reg8_reg8 sc0,H_reg,L_reg
	get_op
	 
.align 4
x66: @LD H,(HL)

	 
.align 4
x67: @LD H,A
	ld_reg8_reg8 sc0,H_reg,A_reg
	get_op
	 
.align 4
x68: @LD L,B
	ld_reg8_reg8 sc0,L_reg,B_reg
	get_op
	 
.align 4
x69: @LD L,C
	ld_reg8_reg8 sc0,L_reg,C_reg
	get_op
	 
.align 4
x6a: @LD L,D
	ld_reg8_reg8 sc0,L_reg,D_reg
	get_op
	 
.align 4
x6b: @LD L,E
	ld_reg8_reg8 sc0,L_reg,E_reg
	get_op
	 
.align 4
x6c: @LD L,H
	ld_reg8_reg8 sc0,L_reg,H_reg
	get_op
	 
.align 4
x6d: @LD L,L
	get_op
	 
.align 4
x6e: @LD L,(HL)


.align 4
x6f: @LD L,A
	ld_reg8_reg8 sc0,L_reg,A_reg
	get_op
	 

.align 4
x70: @LD (HL),B
	ldrb sc0,[cpuregs,B_reg]
	ld_ra16_d8 HL_reg,sc0,sc1,sc2
	get_op
	
.ltorg
	
.align 4
x71: @LD (HL),C
	ldrb sc0,[cpuregs,C_reg]
	ld_ra16_d8 HL_reg,sc0,sc1,sc2
	get_op
	 
.ltorg

.align 4
x72: @LD (HL),D
	ldrb sc0,[cpuregs,D_reg]
	ld_ra16_d8 HL_reg,sc0,sc1,sc2
	get_op
	 


.align 4
x73: @LD (HL),E
	ldrb sc0,[cpuregs,E_reg]
	ld_ra16_d8 HL_reg,sc0,sc1,sc2
	get_op

.ltorg 

.align 4
x74: @LD (HL),H
	ldrb sc0,[cpuregs,H_reg]
	ld_ra16_d8 HL_reg,sc0,sc1,sc2
	get_op
 
.ltorg

.align 4
x75: @LD (HL),L
	ldrb sc0,[cpuregs,L_reg]
	ld_ra16_d8 HL_reg,sc0,sc1,sc2
	get_op
	 
.ltorg

.align 4
x76: @HALT - clock stopped, oscillator and lcd controller keep going. cancelled by interrupt or reset signal
	@wait for interrupts
	get_op
	 
.ltorg

.align 4
x77: @LD (HL),A
	ldrb sc2,[cpuregs,A_reg]  @sc2 holds the data
	ldrh sc1,[cpuregs,HL_reg] @sc1 holds the 16-bit address
	add sc0,sc1,1			  @sc0 holds (16-bit addr + 1)
	tst sc0,0x10000			  @check for IER
	bne IER_write77
	mov sc0,0xfe00
	subs sc0,sc1,sc0		  @check if in lower memory space
	bmi lower77					  @pass rA to lower
	mov sc1,0x100
	subs sc1,sc0,sc1		  @check if in OAM
	bmi OAM_write77				  @pass RB to OAM
	subs sc0,sc1,0x80		  @check if in IO
	bmi IO_write77				  @pass RA to IO
	ldr sc0,=hram			  @it is in HRAM
	strb sc2,[sc0,sc1]		  @store RB in HRAM
	get_op

IER_write77:
	@sc2 has value writing to IER
	get_op

OAM_write77:
	@sc0 has low 8 bits of address
	get_op

IO_write77:
	@sc0 has low 8 bits of address
	get_op

lower77: @sc1 holds the 16-bit address
	mov sc0,0x8000
	subs sc0,sc1,sc0				@check if in cart
	ittt mi
	strbmi sc2,[cartaddr,sc1]
	get_opmi
	mov sc1,0x2000
	subs sc1,sc0,sc1				@check if in vram
	itttt mi
	ldrmi sc1,=vramn
	strbmi sc2,[sc1,sc0]
	get_opmi
	mov sc0,0x2000
	ldr sc4,=0x61000000					@I have to move this out of the block
	@ldr sc4,[sc4]					@IT can only have 4 conditions, I need 5
	subs sc0,sc1,sc0				@check if in extram
	ittt mi
	strbmi sc2,[sc4,sc1]
	get_opmi
	mov sc1,0x1000
	subs sc1,sc0,sc1				@check if in wram0
	itttt mi
	ldrmi sc1,=wram0
	strbmi sc2,[sc1,sc0]
	get_opmi
	ldr sc0,=wramn					@it is in wramn
	strb sc2,[sc0,sc1]				@the last get_op is outside the macro so the breakpoint in get_op is hit
	get_op


.ltorg
	 
.align 4
x78: @LD A,B
	ld_reg8_reg8 sc0,A_reg,B_reg
	get_op
	 
.align 4
x79: @LD A,C - no flags
	ld_reg8_reg8 sc0,A_reg,C_reg
	get_op
	 
.align 4
x7a: @LD A,D
	ld_reg8_reg8 sc0,A_reg,D_reg
	get_op
	 
.align 4
x7b: @LD A,E
	ld_reg8_reg8 sc0,A_reg,E_reg
	get_op
	 
.align 4
x7c: @LD A,H
	ld_reg8_reg8 sc0,A_reg,H_reg
	get_op
	 
.align 4
x7d: @LD A,L
	ld_reg8_reg8 sc0,A_reg,L_reg
	get_op
	 
.align 4
x7e: @LD A,(HL)

	 
.align 4
x7f: @LD A,A
	get_op
	 
.align 4
x80: @ADD A,B
	add_reg8_reg8 r0,r8,r9,A_reg,B_reg
	get_op
	 
.align 4
x81: @ADD A,C
	add_reg8_reg8 r0,r8,r9,A_reg,C_reg
	get_op
	 
.align 4
x82: @ADD A,D
	add_reg8_reg8 r0,r8,r9,A_reg,D_reg
	get_op
	 
.align 4
x83: @ADD A,E
	add_reg8_reg8 r0,r8,r9,A_reg,E_reg
	get_op
	 
.align 4
x84: @ADD A,H
	add_reg8_reg8 r0,r8,r9,A_reg,H_reg
	get_op
	 
.align 4
x85: @ADD A,L
	add_reg8_reg8 r0,r8,r9,A_reg,L_reg
	get_op
	 
.align 4
x86: @ADD A,(HL)

	 
.align 4
x87: @ADD A,A
	add_regA_regA r0
	get_op
	 
.align 4
x88: @ADC A,B
	adc_reg8_reg8 r0,r8,r9,A_reg,B_reg
	get_op
	 
.align 4
x89: @ADC A,C
	adc_reg8_reg8 r0,r8,r9,A_reg,C_reg
	get_op
	 
.align 4
x8a: @ADC A,D
	adc_reg8_reg8 r0,r8,r9,A_reg,D_reg
	get_op
	 
.align 4
x8b: @ADC A,E
	adc_reg8_reg8 r0,r8,r9,A_reg,E_reg
	get_op
	 
.align 4
x8c: @ADC A,H
	adc_reg8_reg8 r0,r8,r9,A_reg,H_reg
	get_op
	 
.align 4
x8d: @ADC A,L
	adc_reg8_reg8 r0,r8,r9,A_reg,L_reg
	get_op
	 
.align 4
x8e: @ADC A,(HL)

	 
.align 4
x8f: @ADC A,A
	adc_regA_regA r0
	get_op
	 
.align 4
x90: @SUB B
	sub_A_reg8 r0,r8,r9,B_reg
	get_op 

.align 4
x91: @SUB C
	sub_A_reg8 r0,r8,r9,C_reg
	get_op 
	 
.align 4
x92: @SUB D
	sub_A_reg8 r0,r8,r9,D_reg
	get_op 
	 
.align 4
x93: @SUB E
	sub_A_reg8 r0,r8,r9,E_reg
	get_op 
	 
.align 4
x94: @SUB H
	sub_A_reg8 r0,r8,r9,H_reg
	get_op 
	 
.align 4
x95: @SUB L
	sub_A_reg8 r0,r8,r9,L_reg
	get_op 
	 
.align 4
x96: @SUB (HL)

	 
.align 4
x97: @SUB A
	mov sc0,0
	strb sc0,[cpuregs,A_reg]
	mov cpuregs,0xc0	@Z,N = 1; H,C = 0
	get_op
	 
.align 4
x98: @SBC A,B
	sbc_A_reg8 r0,r8,r9,B_reg
	get_op 
	 
.align 4
x99: @SBC A,C
	sbc_A_reg8 r0,r8,r9,C_reg
	get_op 
	 
.align 4
x9a: @SBC A,D
	sbc_A_reg8 r0,r8,r9,D_reg
	get_op 
	 
.align 4
x9b: @SBC A,E
	sbc_A_reg8 r0,r8,r9,E_reg
	get_op 
	 
.align 4
x9c: @SBC A,H
	sbc_A_reg8 r0,r8,r9,H_reg
	get_op 
	 
.align 4
x9d: @SBC A,L
	sbc_A_reg8 r0,r8,r9,L_reg
	get_op 
	 
.align 4
x9e: @SBC A,(HL)
	get_op
	 
.align 4
x9f: @SBC A,A
	tst cpuflags,cflag_set
	ittee eq
	moveq r0,0xff
	moveq cpuflags,0x70  @Z=0; H,C,N = 1
	movne r0,0
	movne cpuflags,0xc0	@Z,N = 1; H,C = 0
	strb r0,[cpuregs,A_reg]
	get_op
	 
.align 4
xa0: @AND B
	and_A_reg8 sc0,sc1,B_reg
	get_op
	 
.align 4
xa1: @AND C
	and_A_reg8 sc0,sc1,C_reg
	get_op
	 
.align 4
xa2: @AND D
	and_A_reg8 sc0,sc1,D_reg
	get_op
	 
.align 4
xa3: @AND E
	and_A_reg8 sc0,sc1,E_reg
	get_op
	 
.align 4
xa4: @AND H
	and_A_reg8 sc0,sc1,H_reg
	get_op
	 
.align 4
xa5: @AND L
	and_A_reg8 sc0,sc1,L_reg
	get_op
	 
.align 4
xa6: @AND (HL)

	 
.align 4
xa7: @AND A
	ldrb sc0,[cpuregs,A_reg]
	tst sc0,sc0
	ite eq
	moveq cpuflags,0xa0    @Z,H = 1; N,C = 0
	movne cpuflags,0x20	  @H = 1; Z,N,C = 0
	get_op
	 
.align 4
xa8: @XOR B

	 
.align 4
xa9: @XOR C

	 
.align 4
xaa: @XOR D

	 
.align 4
xab: @XOR E

	 
.align 4
xac: @XOR H

	 
.align 4
xad: @XOR L

	 
.align 4
xae: @XOR (HL)

	 
.align 4
xaf: @XOR A - A^A, Z is set if 0, NHC cleared

	 
.align 4
xb0: @OR B - Logical OR with A, store result in A - z if result is 0, nhc are reset
 
	 
.align 4
xb1: @OR C

	 
.align 4
xb2: @OR D

	 
.align 4
xb3: @OR E

	 
.align 4
xb4: @OR H

	 
.align 4
xb5: @OR L

	 
.align 4
xb6: @OR (HL)

	 
.align 4
xb7: @OR A

	 
.align 4
xb8: @CP B
	cp_A_reg8 sc0,sc1,B_reg
	get_op
	 
.align 4
xb9: @CP C
	cp_A_reg8 sc0,sc1,C_reg
	get_op
	 
.align 4
xba: @CP D
	cp_A_reg8 sc0,sc1,D_reg
	get_op
	 
.align 4
xbb: @CP E
	cp_A_reg8 sc0,sc1,E_reg
	get_op
	 
.align 4
xbc: @CP H
	cp_A_reg8 sc0,sc1,H_reg
	get_op
	 
.align 4
xbd: @CP L
	cp_A_reg8 sc0,sc1,L_reg
	get_op
	 
.align 4
xbe: @CP (HL)

	 
.align 4
xbf: @CP A - I feel like this is too easy, CP A is always going to be 0
	mov cpuflags,0xc0
	get_op
	 
.align 4
xc0: @RET NZ

	 
.align 4
xc1: @POP BC

	 
.align 4
xc2: @JP NZ,a16
	get_2_arg
	tst cpuflags,zflag_set
	it eq			@zflag is not set if result of tst is 0
	addeq progc,args,cartaddr
	get_op

.align 4
xc3: @JP a16
	get_2_arg
	add progc,args,cartaddr
	get_op

.align 4
xc4: @CALL NZ,a16

	 
.align 4
xc5: @PUSH BC

	 
.align 4
xc6: @ADD A,d8

	 
.align 4
xc7: @RST 00H

	 
.align 4
xc8: @RET Z

	 
.align 4
xc9: @RET

	 
.align 4
xca: @JP Z,a16
	get_2_arg
	tst cpuflags,zflag_set
	it ne
	addne progc,args,cartaddr
	get_op

	 
.align 4
xcb: @PREFIX CB
	get_1_arg	@args holds the CB opcode
	ldr sc0,=cb_lbl
#ifdef debug_bkpts
	bkpt 22
#endif
	ldr pc,[sc0,args,lsl 2]
	 
.align 4
xcc: @CALL Z,a16

	 
.align 4
xcd: @CALL a16 - push addr of next instruction to stack and jump to a16

	 
.align 4
xce: @ADC A,d8

	 
.align 4
xcf: @RST 08H

	 
.align 4
xd0: @RET NC

	 
.align 4
xd1: @POP DE

	 
.align 4
xd2: @JP NC,a16

	 
.align 4
xd3: @unused

	 
.align 4
xd4: @CALL NC,a16

	 
.align 4
xd5: @PUSH DE

	 
.align 4
xd6: @SUB d8

	 
.align 4
xd7: @RST 10H

	 
.align 4
xd8: @RET C

	 
.align 4
xd9: @RETI

	 
.align 4
xda: @JP C,a16

	 
.align 4
xdb: @unused
	 
.align 4
xdc: @CALL C,a16

	 
.align 4
xdd:@unused
	 
.align 4
xde: @SBC A,d8

	 
.align 4
xdf: @RST 18H

	 
.align 4
xe0: @LDH (a8),A

	 
.align 4
xe1: @POP HL

	 
.align 4
xe2: @LD (C),A - write to IO port at address (0xFF00 + (C)) the contents of A

	 
.align 4
xe3:@unused
	 
.align 4
xe4:@unused
	 
.align 4
xe5: @PUSH HL

	 
.align 4
xe6: @AND d8 - Z is set if AND is 0, N is reset, H is set, C is reset

	 
.align 4
xe7: @RST 20H

	 
.align 4
xe8: @ADD SP,r8

	 
.align 4
xe9: @JP (HL)

	 
.align 4
xea: @LD (a16),A - put A into address (a16) addr fix
	get_2_arg
	strh args,[cpuregs,SC_reg]
	ldrb sc0,[cpuregs,A_reg]
	ld_ra16_d8 SC_reg,sc0,sc1,sc2
	get_op
	 
.ltorg

.align 4
xeb:@unused
	 
.align 4
xec:@unused
	 
.align 4
xed:@unused
	 
.align 4
xee: @XOR d8

	 
.align 4
xef: @RST 28H

	 
.align 4
xf0: @LDH A,(a8) - store the address (0xFF00 + a8) into A - I/O DATA

.align 4
xf1: @POP AF

	 
.align 4
xf2: @LD A,(C) - Load (0xFF00 + (C)) into reg A (read i/o into A)
	

.align 4
xf3: @Disable interrupts
	@do something
	get_op

.align 4
xf4:@unused
	 
.align 4
xf5: @PUSH AF

	 
.align 4
xf6: @OR d8

	 
.align 4
xf7: @RST 30H

	 
.align 4
xf8: @LD HL,SP+r8

	 
.align 4
xf9: @LD SP,HL

	 
.align 4
xfa: @LD A,(a16)

	 
.align 4
xfb: @EI
	 
.align 4
xfc:@unused
	 
.align 4
xfd:@unused


.align 4
xfe: @CP d8 - compare A with d8 - (A - d8) - Set N, conditionally set Z,H, C is set if A < d8
	get_1_arg
	ldrb sc0,[cpuregs,A_reg]
	mov sc1,args		@moving args to sc1 so args isnt clobbered, for debugging reasons
	cmp sc0,sc1
	ittt eq
	moveq cpuflags,0xc0
	get_opeq
	ite mi				@they are not equal
	movmi cpuflags,0x50 @negative - N and C flags set
	movpl cpuflags,0x60	@gt or eq - N set, Z and C flags clear
	and sc0,0xf
	and sc1,0xf
	cmp sc0,sc1
	it mi
	orrmi cpuflags,hflag_set
	get_op

.align 4
xff: @RST 38H



.align 4
cb00: @RLC B - Rotate B. old bit 7 goes to carry and to bit 0. Z is conditionally set, N,H cleared
	cb_rlc_r8 sc0,B_reg
	get_op

.align 4
cb01: @RLC,C
	cb_rlc_r8 sc0,C_reg
	get_op

.align 4
cb02: @RLC,D
	cb_rlc_r8 sc0,D_reg
	get_op

.align 4
cb03: @RLC,E
	cb_rlc_r8 sc0,E_reg
	get_op

.align 4
cb04: @RLC,H
	cb_rlc_r8 sc0,H_reg
	get_op

.align 4
cb05: @RLC,L
	cb_rlc_r8 sc0,L_reg
	get_op

.align 4
cb06: @RLC,(HL)


.align 4
cb07: @RLC,A
	cb_rlc_r8 sc0,A_reg
	get_op

.align 4
cb08: @RRC,B
	cb_rrc_r8 sc0,B_reg
	get_op

.align 4
cb09: @RRC,C
	cb_rrc_r8 sc0,C_reg
	get_op

.align 4
cb0a: @RRC,D
	cb_rrc_r8 sc0,D_reg
	get_op

.align 4
cb0b: @RRC,E
	cb_rrc_r8 sc0,E_reg
	get_op

.align 4
cb0c: @RRC,H
	cb_rrc_r8 sc0,H_reg
	get_op

.align 4
cb0d: @RRC,L
	cb_rrc_r8 sc0,L_reg
	get_op

.align 4
cb0e: @RRC,(HL)


.align 4
cb0f: @RRC,A
	cb_rrc_r8 sc0,A_reg
	get_op

.align 4
cb10: @RL,B
	cb_rl_r8 sc0,B_reg
	get_op

.align 4
cb11: @RL,C
	cb_rl_r8 sc0,C_reg
	get_op

.align 4
cb12: @RL,D
	cb_rl_r8 sc0,D_reg
	get_op

.align 4
cb13: @RL,E
	cb_rl_r8 sc0,E_reg
	get_op

.align 4
cb14: @RL,H
	cb_rl_r8 sc0,H_reg
	get_op

.align 4
cb15: @RL,L
	cb_rl_r8 sc0,L_reg
	get_op

.align 4
cb16: @RL,(HL)


.align 4
cb17: @RL,A
	cb_rl_r8 sc0,A_reg
	get_op

.align 4
cb18: @RR,B
	cb_rr_r8 sc0,B_reg
	get_op

.align 4
cb19: @RR,C
	cb_rr_r8 sc0,C_reg
	get_op

.align 4
cb1a: @RR,D
	cb_rr_r8 sc0,D_reg
	get_op

.align 4
cb1b: @RR,E
	cb_rr_r8 sc0,E_reg
	get_op

.align 4
cb1c: @RR,H
	cb_rr_r8 sc0,H_reg
	get_op

.align 4
cb1d: @RR,L
	cb_rr_r8 sc0,L_reg
	get_op

.align 4
cb1e: @RR,(HL)


.align 4
cb1f: @RR,A
	cb_rr_r8 sc0,A_reg
	get_op

.align 4
cb20: @SLA,B
	cb_sla_r8 sc0,B_reg
	get_op

.align 4
cb21: @SLA,C
	cb_sla_r8 sc0,C_reg
	get_op

.align 4
cb22: @SLA,D
	cb_sla_r8 sc0,D_reg
	get_op

.align 4
cb23: @SLA,E
	cb_sla_r8 sc0,E_reg
	get_op

.align 4
cb24: @SLA,H
	cb_sla_r8 sc0,H_reg
	get_op

.align 4
cb25: @SLA,L
	cb_sla_r8 sc0,L_reg
	get_op

.align 4
cb26: @SLA,(HL)


.align 4
cb27: @SLA,A
	cb_sla_r8 sc0,A_reg
	get_op

.align 4
cb28: @SRA,B
	cb_sra_r8 sc0,B_reg
	get_op

.align 4
cb29: @SRA,C
	cb_sra_r8 sc0,C_reg
	get_op

.align 4
cb2a: @SRA,D
	cb_sra_r8 sc0,D_reg
	get_op

.align 4
cb2b: @SRA,E
	cb_sra_r8 sc0,E_reg
	get_op

.align 4
cb2c: @SRA,H
	cb_sra_r8 sc0,H_reg
	get_op

.align 4
cb2d: @SRA,L
	cb_sra_r8 sc0,L_reg
	get_op

.align 4
cb2e: @SRA,(HL)


.align 4
cb2f: @SRA,A
	cb_sra_r8 sc0,A_reg
	get_op

.align 4
cb30: @SWAP B - set z conditionally, N,H,C cleared
	cb_swap_r8 sc0,B_reg
	get_op

.align 4
cb31: @SWAP C
	cb_swap_r8 sc0,C_reg
	get_op

.align 4
cb32: @SWAP D
	cb_swap_r8 sc0,D_reg
	get_op

.align 4
cb33: @SWAP E
	cb_swap_r8 sc0,E_reg
	get_op

.align 4
cb34: @SWAP H
	cb_swap_r8 sc0,H_reg
	get_op

.align 4
cb35: @SWAP L
	cb_swap_r8 sc0,L_reg
	get_op

.align 4
cb36: @SWAP (HL)
	get_op

.align 4
cb37: @SWAP A
	cb_swap_r8 sc0,A_reg
	get_op

.align 4
cb38: @SRL,B
	cb_srl_r8 sc0,B_reg
	get_op

.align 4
cb39: @SRL,C
	cb_srl_r8 sc0,C_reg
	get_op

.align 4
cb3a: @SRL,D
	cb_srl_r8 sc0,D_reg
	get_op

.align 4
cb3b: @SRL,E
	cb_srl_r8 sc0,E_reg
	get_op

.align 4
cb3c: @SRL,H
	cb_srl_r8 sc0,H_reg
	get_op

.align 4
cb3d: @SRL,L
	cb_srl_r8 sc0,L_reg
	get_op

.align 4
cb3e: @SRL,(HL)


.align 4
cb3f: @SRL,A
	cb_srl_r8 sc0,A_reg
	get_op

.align 4
cb40: @BIT 0,B
	cb_bit sc0,0,B_reg
	get_op

.align 4
cb41: @BIT 0,C
	cb_bit sc0,0,C_reg
	get_op

.align 4
cb42: @BIT 0,D
	cb_bit sc0,0,D_reg
	get_op

.align 4
cb43: @BIT 0,E
	cb_bit sc0,0,E_reg
	get_op

.align 4
cb44: @BIT 0,H
	cb_bit sc0,0,H_reg
	get_op

.align 4
cb45: @BIT 0,L
	cb_bit sc0,0,L_reg
	get_op

.align 4
cb46: @BIT 0,(HL)

.align 4
cb47: @BIT 0,A
	cb_bit sc0,0,A_reg
	get_op

.align 4
cb48: @BIT 1,B
	cb_bit sc0,1,B_reg
	get_op

.align 4
cb49: @BIT 1,C
	cb_bit sc0,1,C_reg
	get_op

.align 4
cb4a: @BIT 1,D
	cb_bit sc0,1,D_reg
	get_op

.align 4
cb4b: @BIT 1,E
	cb_bit sc0,1,E_reg
	get_op

.align 4
cb4c: @BIT 1,H
	cb_bit sc0,1,H_reg
	get_op

.align 4
cb4d: @BIT 1,L
	cb_bit sc0,1,L_reg
	get_op

.align 4
cb4e: @BIT 1,(HL)


.align 4
cb4f: @BIT 1,A
	cb_bit sc0,1,A_reg
	get_op

.align 4
cb50: @BIT 2,B
	cb_bit sc0,2,B_reg
	get_op

.align 4
cb51: @BIT 2,C
	cb_bit sc0,2,C_reg
	get_op

.align 4
cb52: @BIT 2,D
	cb_bit sc0,2,D_reg
	get_op

.align 4
cb53: @BIT 2,E
	cb_bit sc0,2,E_reg
	get_op

.align 4
cb54: @BIT 2,H
	cb_bit sc0,2,H_reg
	get_op

.align 4
cb55: @BIT 2,L
	cb_bit sc0,2,L_reg
	get_op

.align 4
cb56: @BIT 2,(HL)


.align 4
cb57: @BIT 2,A
	cb_bit sc0,2,A_reg
	get_op

.align 4
cb58: @BIT 3,B
	cb_bit sc0,3,B_reg
	get_op

.align 4
cb59: @BIT 3,C
	cb_bit sc0,3,C_reg
	get_op

.align 4
cb5a: @BIT 3,D
	cb_bit sc0,3,D_reg
	get_op

.align 4
cb5b: @BIT 3,E
	cb_bit sc0,3,E_reg
	get_op

.align 4
cb5c: @BIT 3,H
	cb_bit sc0,3,H_reg
	get_op

.align 4
cb5d: @BIT 3,L
	cb_bit sc0,3,L_reg
	get_op

.align 4
cb5e: @BIT 3,(HL)


.align 4
cb5f: @BIT 3,A
	cb_bit sc0,3,A_reg
	get_op

.align 4
cb60: @BIT 4,B
	cb_bit sc0,4,B_reg
	get_op

.align 4
cb61: @BIT 4,C
	cb_bit sc0,4,C_reg
	get_op

.align 4
cb62: @BIT 4,D
	cb_bit sc0,4,D_reg
	get_op

.align 4
cb63: @BIT 4,E
	cb_bit sc0,4,E_reg
	get_op

.align 4
cb64: @BIT 4,H
	cb_bit sc0,4,H_reg
	get_op

.align 4
cb65: @BIT 4,L
	cb_bit sc0,4,L_reg
	get_op

.align 4
cb66: @BIT 4,(HL)


.align 4
cb67: @BIT 4,A
	cb_bit sc0,4,A_reg
	get_op

.align 4
cb68: @BIT 5,B
	cb_bit sc0,5,B_reg
	get_op

.align 4
cb69: @BIT 5,C
	cb_bit sc0,5,C_reg
	get_op

.align 4
cb6a: @BIT 5,D
	cb_bit sc0,5,D_reg
	get_op

.align 4
cb6b: @BIT 5,E
	cb_bit sc0,5,E_reg
	get_op

.align 4
cb6c: @BIT 5,H
	cb_bit sc0,5,H_reg
	get_op

.align 4
cb6d: @BIT 5,L
	cb_bit sc0,5,L_reg
	get_op

.align 4
cb6e: @BIT 5,(HL)


.align 4
cb6f: @BIT 5,A
	cb_bit sc0,5,A_reg
	get_op

.align 4
cb70: @BIT 6,B
	cb_bit sc0,6,B_reg
	get_op

.align 4
cb71: @BIT 6,C
	cb_bit sc0,6,C_reg
	get_op

.align 4
cb72: @BIT 6,D
	cb_bit sc0,6,D_reg
	get_op

.align 4
cb73: @BIT 6,E
	cb_bit sc0,6,E_reg
	get_op

.align 4
cb74: @BIT 6,H
	cb_bit sc0,6,H_reg
	get_op

.align 4
cb75: @BIT 6,L
	cb_bit sc0,6,L_reg
	get_op

.align 4
cb76: @BIT 6,(HL)


.align 4
cb77: @BIT 6,A
	cb_bit sc0,6,A_reg
	get_op

.align 4
cb78: @BIT 7,B
	cb_bit sc0,7,B_reg
	get_op

.align 4
cb79: @BIT 7,C
	cb_bit sc0,7,C_reg
	get_op

.align 4
cb7a: @BIT 7,D
	cb_bit sc0,7,D_reg
	get_op

.align 4
cb7b: @BIT 7,E
	cb_bit sc0,7,E_reg
	get_op

.align 4
cb7c: @BIT 7,H
	cb_bit sc0,7,H_reg
	get_op

.align 4
cb7d: @BIT 7,L
	cb_bit sc0,7,L_reg
	get_op

.align 4
cb7e: @BIT 7,(HL)


.align 4
cb7f: @BIT 7,A
	cb_bit sc0,7,A_reg
	get_op


.align 4
cb80: @RES 0,B
	cb_reset_bit sc0,0,B_reg
	get_op

.align 4
cb81: @RES 0,C
	cb_reset_bit sc0,0,C_reg
	get_op

.align 4
cb82: @RES 0,D
	cb_reset_bit sc0,0,D_reg
	get_op

.align 4
cb83: @RES 0,E
	cb_reset_bit sc0,0,E_reg
	get_op

.align 4
cb84: @RES 0,H
	cb_reset_bit sc0,0,H_reg
	get_op

.align 4
cb85: @RES 0,L
	cb_reset_bit sc0,0,L_reg
	get_op

.align 4
cb86: @RES 0,(HL)


.align 4
cb87: @RES 0,A
	cb_reset_bit sc0,0,A_reg
	get_op

.align 4
cb88: @RES 1,B
	cb_reset_bit sc0,1,B_reg
	get_op

.align 4
cb89: @RES 1,C
	cb_reset_bit sc0,1,C_reg
	get_op

.align 4
cb8a: @RES 1,D
	cb_reset_bit sc0,1,D_reg
	get_op

.align 4
cb8b: @RES 1,E
	cb_reset_bit sc0,1,E_reg
	get_op

.align 4
cb8c: @RES 1,H
	cb_reset_bit sc0,1,H_reg
	get_op

.align 4
cb8d: @RES 1,L
	cb_reset_bit sc0,1,L_reg
	get_op

.align 4
cb8e: @RES 1,(HL)


.align 4
cb8f: @RES 1,A
	cb_reset_bit sc0,1,A_reg
	get_op

.align 4
cb90: @RES 2,B
	cb_reset_bit sc0,2,B_reg
	get_op

.align 4
cb91: @RES 2,C
	cb_reset_bit sc0,2,C_reg
	get_op

.align 4
cb92: @RES 2,D
	cb_reset_bit sc0,2,D_reg
	get_op

.align 4
cb93: @RES 2,E
	cb_reset_bit sc0,2,E_reg
	get_op

.align 4
cb94: @RES 2,H
	cb_reset_bit sc0,2,H_reg
	get_op

.align 4
cb95: @RES 2,L
	cb_reset_bit sc0,2,L_reg
	get_op

.align 4
cb96: @RES 2,(HL)


.align 4
cb97: @RES 2,A
	cb_reset_bit sc0,2,A_reg
	get_op

.align 4
cb98: @RES 3,B
	cb_reset_bit sc0,3,B_reg
	get_op

.align 4
cb99: @RES 3,C
	cb_reset_bit sc0,3,C_reg
	get_op

.align 4
cb9a: @RES 3,D
	cb_reset_bit sc0,3,D_reg
	get_op

.align 4
cb9b: @RES 3,E
	cb_reset_bit sc0,3,E_reg
	get_op

.align 4
cb9c: @RES 3,H
	cb_reset_bit sc0,3,H_reg
	get_op

.align 4
cb9d: @RES 3,L
	cb_reset_bit sc0,3,L_reg
	get_op

.align 4
cb9e: @RES 3,(HL)


.align 4
cb9f: @RES 3,A
	cb_reset_bit sc0,3,A_reg
	get_op

.align 4
cba0: @RES 4,B
	cb_reset_bit sc0,4,B_reg
	get_op

.align 4
cba1: @RES 4,C
	cb_reset_bit sc0,4,C_reg
	get_op

.align 4
cba2: @RES 4,D
	cb_reset_bit sc0,4,D_reg
	get_op

.align 4
cba3: @RES 4,E
	cb_reset_bit sc0,4,E_reg
	get_op

.align 4
cba4: @RES 4,H
	cb_reset_bit sc0,4,H_reg
	get_op

.align 4
cba5: @RES 4,L
	cb_reset_bit sc0,4,L_reg
	get_op

.align 4
cba6: @RES 4,(HL)


.align 4
cba7: @RES 4,A
	cb_reset_bit sc0,4,A_reg
	get_op

.align 4
cba8: @RES 5,B
	cb_reset_bit sc0,5,B_reg
	get_op

.align 4
cba9: @RES 5,C
	cb_reset_bit sc0,5,C_reg
	get_op

.align 4
cbaa: @RES 5,D
	cb_reset_bit sc0,5,D_reg
	get_op

.align 4
cbab: @RES 5,E
	cb_reset_bit sc0,5,E_reg
	get_op

.align 4
cbac: @RES 5,H
	cb_reset_bit sc0,5,H_reg
	get_op

.align 4
cbad: @RES 5,L
	cb_reset_bit sc0,5,L_reg
	get_op

.align 4
cbae: @RES 5,(HL)


.align 4
cbaf: @RES 5,A
	cb_reset_bit sc0,5,A_reg
	get_op

.align 4
cbb0: @RES 6,B
	cb_reset_bit sc0,6,B_reg
	get_op

.align 4
cbb1: @RES 6,C
	cb_reset_bit sc0,6,C_reg
	get_op

.align 4
cbb2: @RES 6,D
	cb_reset_bit sc0,6,D_reg
	get_op

.align 4
cbb3: @RES 6,E
	cb_reset_bit sc0,6,E_reg
	get_op

.align 4
cbb4: @RES 6,H
	cb_reset_bit sc0,6,H_reg
	get_op

.align 4
cbb5: @RES 6,L
	cb_reset_bit sc0,6,L_reg
	get_op

.align 4
cbb6: @RES 6,(HL)


.align 4
cbb7: @RES 6,A
	cb_reset_bit sc0,6,A_reg
	get_op

.align 4
cbb8: @RES 7,B
	cb_reset_bit sc0,7,B_reg
	get_op

.align 4
cbb9: @RES 7,C
	cb_reset_bit sc0,7,C_reg
	get_op

.align 4
cbba: @RES 7,D
	cb_reset_bit sc0,7,D_reg
	get_op

.align 4
cbbb: @RES 7,E
	cb_reset_bit sc0,7,E_reg
	get_op

.align 4
cbbc: @RES 7,H
	cb_reset_bit sc0,7,H_reg
	get_op

.align 4
cbbd: @RES 7,L
	cb_reset_bit sc0,7,L_reg
	get_op

.align 4
cbbe: @RES 7,(HL)


.align 4
cbbf: @RES 7,A
	cb_reset_bit sc0,7,A_reg
	get_op

.align 4
cbc0: @SET 0,B
	cb_set_bit sc0,0,B_reg
	get_op

.align 4
cbc1: @SET 0,C
	cb_set_bit sc0,0,C_reg
	get_op

.align 4
cbc2: @SET 0,D
	cb_set_bit sc0,0,D_reg
	get_op

.align 4
cbc3: @SET 0,E
	cb_set_bit sc0,0,E_reg
	get_op

.align 4
cbc4: @SET 0,H
	cb_set_bit sc0,0,H_reg
	get_op

.align 4
cbc5: @SET 0,L
	cb_set_bit sc0,0,L_reg
	get_op

.align 4
cbc6: @SET 0,(HL)


.align 4
cbc7: @SET 0,A
	cb_set_bit sc0,0,A_reg
	get_op

.align 4
cbc8: @SET 1,B
	cb_set_bit sc0,1,B_reg
	get_op

.align 4
cbc9: @SET 1,C
	cb_set_bit sc0,1,C_reg
	get_op

.align 4
cbca: @SET 1,D
	cb_set_bit sc0,1,D_reg
	get_op

.align 4
cbcb: @SET 1,E
	cb_set_bit sc0,1,E_reg
	get_op

.align 4
cbcc: @SET 1,H
	cb_set_bit sc0,1,H_reg
	get_op

.align 4
cbcd: @SET 1,L
	cb_set_bit sc0,1,L_reg
	get_op

.align 4
cbce: @SET 1,(HL)


.align 4
cbcf: @SET 1,A
	cb_set_bit sc0,1,A_reg
	get_op

.align 4
cbd0: @SET 2,B
	cb_set_bit sc0,2,B_reg
	get_op

.align 4
cbd1: @SET 2,C
	cb_set_bit sc0,2,C_reg
	get_op

.align 4
cbd2: @SET 2,D
	cb_set_bit sc0,2,D_reg
	get_op

.align 4
cbd3: @SET 2,E
	cb_set_bit sc0,2,E_reg
	get_op

.align 4
cbd4: @SET 2,H
	cb_set_bit sc0,2,H_reg
	get_op

.align 4
cbd5: @SET 2,L
	cb_set_bit sc0,2,L_reg
	get_op

.align 4
cbd6: @SET 2,(HL)


.align 4
cbd7: @SET 2,A
	cb_set_bit sc0,2,A_reg
	get_op

.align 4
cbd8: @SET 3,B
	cb_set_bit sc0,3,B_reg
	get_op

.align 4
cbd9: @SET 3,C
	cb_set_bit sc0,3,C_reg
	get_op

.align 4
cbda: @SET 3,D
	cb_set_bit sc0,3,D_reg
	get_op

.align 4
cbdb: @SET 3,E
	cb_set_bit sc0,3,E_reg
	get_op

.align 4
cbdc: @SET 3,H
	cb_set_bit sc0,3,H_reg
	get_op

.align 4
cbdd: @SET 3,L
	cb_set_bit sc0,3,L_reg
	get_op

.align 4
cbde: @SET 3,(HL)


.align 4
cbdf: @SET 3,A
	cb_set_bit sc0,3,A_reg
	get_op

.align 4
cbe0: @SET 4,B
	cb_set_bit sc0,4,B_reg
	get_op

.align 4
cbe1: @SET 4,C
	cb_set_bit sc0,4,C_reg
	get_op

.align 4
cbe2: @SET 4,D
	cb_set_bit sc0,4,D_reg
	get_op

.align 4
cbe3: @SET 4,E
	cb_set_bit sc0,4,E_reg
	get_op

.align 4
cbe4: @SET 4,H
	cb_set_bit sc0,4,H_reg
	get_op

.align 4
cbe5: @SET 4,L
	cb_set_bit sc0,4,L_reg
	get_op

.align 4
cbe6: @SET 4,(HL)


.align 4
cbe7: @SET 4,A
	cb_set_bit sc0,4,A_reg
	get_op

.align 4
cbe8: @SET 5,B
	cb_set_bit sc0,5,B_reg
	get_op

.align 4
cbe9: @SET 5,C
	cb_set_bit sc0,5,C_reg
	get_op

.align 4
cbea: @SET 5,D
	cb_set_bit sc0,5,D_reg
	get_op

.align 4
cbeb: @SET 5,E
	cb_set_bit sc0,5,E_reg
	get_op

.align 4
cbec: @SET 5,H
	cb_set_bit sc0,5,H_reg
	get_op

.align 4
cbed: @SET 5,L
	cb_set_bit sc0,5,L_reg
	get_op

.align 4
cbee: @SET 5,(HL)


.align 4
cbef: @SET 5,A
	cb_set_bit sc0,5,A_reg
	get_op

.align 4
cbf0: @SET 6,B
	cb_set_bit sc0,6,B_reg
	get_op

.align 4
cbf1: @SET 6,C
	cb_set_bit sc0,6,C_reg
	get_op

.align 4
cbf2: @SET 6,D
	cb_set_bit sc0,6,D_reg
	get_op

.align 4
cbf3: @SET 6,E
	cb_set_bit sc0,6,E_reg
	get_op

.align 4
cbf4: @SET 6,H
	cb_set_bit sc0,6,H_reg
	get_op

.align 4
cbf5: @SET 6,L
	cb_set_bit sc0,6,L_reg
	get_op

.align 4
cbf6: @SET 6,(HL)


.align 4
cbf7: @SET 6,A
	cb_set_bit sc0,6,A_reg
	get_op

.align 4
cbf8: @SET 7,B
	cb_set_bit sc0,7,B_reg
	get_op

.align 4
cbf9: @SET 7,C
	cb_set_bit sc0,7,C_reg
	get_op

.align 4
cbfa: @SET 7,D
	cb_set_bit sc0,7,D_reg
	get_op

.align 4
cbfb: @SET 7,E
	cb_set_bit sc0,7,E_reg
	get_op

.align 4
cbfc: @SET 7,H
	cb_set_bit sc0,7,H_reg
	get_op

.align 4
cbfd: @SET 7,L
	cb_set_bit sc0,7,L_reg
	get_op

.align 4
cbfe: @SET 7,(HL)


.align 4
cbff: @SET 7,A
	cb_set_bit sc0,7,A_reg
	get_op



