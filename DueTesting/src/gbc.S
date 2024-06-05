.syntax unified

#include "gbc_funcs.S"

#define debug_bkpts					@ this puts bkpt in get_op
/**#define debug_mem_catch_jmp_tbl		 this puts bkpt in the read/write jump tables**/
@#define debug_mem_catch			@ this jumps exection to routine before continuing execution (not implemented)
@#define debug_ld_A_rr				@ this puts known value into sc4 when exiting ld_A_rr
@#define debug_ld_ra16_d8			@ this puts known value into sc4 when exiting @ld_ra16_d8

@ this needs to be in this file, otherwise I get an "already defined" error
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


.bss
oam: .space 160,0
io: .space 128,0
hram: .space 127,0
ier: .byte 0

.data
.align 4
mem_map: 
wram: .space 0x2000
vram: .space 0x2000
extram: .word =0x6100a000
@pixels: .space 46080



cpu_regs_addr: .space 20
@NOTE: because my CPU flags are in a register, the F register here is never updated
@C B BC E D DE L H HL F A AF  wram      vram      scratch_reg
@Reg order:
@0 1 0  2 3 2  4 5 4  6 7 6   8          12			16

.data

.text

@@@ NOTES @@@
@@@ parameters: address and destination to be set by the caller
@@@ returns: nothing

@@@@@@@@ MEM CATCH MACROS @@@@@@@@

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
wram_read:
	get_op

.align 4
wram_write:
	get_op

.align 4
echo_read:
	get_op

.align 4
echo_write:
	get_op

.align 4
ier_read:
#ifdef debug_mem_catch_jmp_tbl
	nop
	bkpt 0xff
	nop
#endif
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


#define cart 0x60000000
#define extram 0x6100a000

.align 4
mem_lower_lbl:
	.word =cart
	.word =cart
	.word =cart
	.word =cart
	.word =vram
	.word =vram
	.word =extram
	.word =extram
	.word =wram
	.word =wram

@@@@@@@@ MEM CATCH DECISION MACROS @@@@@@@@

@ addr - register with the address
@ data - register with the data
@ sc - free scratch register
.macro mem_catch_read addr,sc
	mov \sc,0xff
	orr \sc,\sc,\sc, lsl 8
	teq \addr,\sc
	beq ier_read\@
	subs \sc,\addr,0xfe00
	itt mi
	ubfxmi \sc,\addr,13,3
	ldrmi pc,[mem_read_lower_tbl,\sc, lsl 2]


ier_read\@:
	get_op	
.endm

@ addr - register with the address
@ data - register with the data
@ sc - free scratch register
.macro mem_catch_write addr,data,sc

.endm


@ For instructions in the format "LD A, (r16)"
@ addr - address to read from
@ cpureg - cpu register numer
@ sc - scratch register
@@@THIS WONT WORK EBCAUSE SOME ADDRESS RANGES ARE MORE THAN 0x1000 LARGE (like vram)
.macro mem_read_rA_r16 addr,cpureg,sc,sc2
	mov \sc2,0xff
	orr \sc2,\sc2,\sc2, lsl 8	@sc2 contains 0xffff
	teq \addr,\sc2				@check if addr is ier
	beq ier_read\@
	subs \sc,\addr,0xfe00	@sc contains (addr - 0xfe00)
	it pl					@upper section of memory
	bpl upper\@
	ubfx \sc,\addr,13,3		@sc contains the offset into the address table
	ldr \sc,[mem_lower_tbl,\sc, lsl 2]	@sc contains the base memory address from the table
	cmp \addr,0x8000		@if the address is in the cart, leave the address alone, otherwise get the offset
	it pl
	andpl \addr,\addr,\sc2, lsr 4 @remove the upper 4 bits - addr contains the address offset
	ldrb \sc2,[\sc,\addr]		  
	strb \sc2,[cpuregs,A_reg]
	get_op

upper\@:
	get_op

ier_read\@:
	get_op

.endm

#undef cart
#undef extram

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


@ OPTIMIZATIONS:
@ For operations that load CPU registers, if the registers are adjacent, I can do one ldrh instead of two ldrb
@ Ldr/strs are 1 cycle faster if they are staggered
@ In some cases, its faster to clear all cpu flags at once and OR them if necesssary

@ Does anything special happen when H/L are written to

@ Resources:
@ https://web.eecs.umich.edu/~prabal/teaching/eecsc373-f10/readings/ARMv7-M_ARM.pdf
@ https://stackoverflow.com/questions/24115899/arm-ldr-instruction-on-pc-register

@ Half-Carry flag:
@ https://robdor.com/2016/08/10/gameboy-emulator-half-carry-flag/

.align 4
.global gbc
gbc:
	mov sc0,0							@ r0 - working reg
	ldr progc,=0x60000100				@ r1 - pc
	ldr stackptr,=wram					@ r2 - stack pointer
	ldr cpuregs,=cpu_regs_addr			@ r3 - cpu registers address
	mov args,0							@ r4 - holds the arguments for opcodes, if they have any
	mov sc1,0							@ r5 - working reg
	mov gbc_op,0						@ r6 - holds current OP
	mov cpuflags,0						@ r7 - cpu flags: 0bZNHCxxxx
	ldr mem_lower_tbl,=mem_lower_lbl		@ r8 - mem lower table addr
	mov sc4,0							@ r9 - free
	ldr cartaddr,=0x60000000			@ r10 - holds cartridge base address
	ldr xlbl_addr,=x_lbl				@ r11 - holds x jump table base address
	mov sc2,0							@ r12 - working reg

	ldr sc0,=vram
	str sc0,[cpuregs,vram_reg]
	ldr sc0,=wram
	str sc0,[cpuregs,wram_reg]

	@ reset the system
	mov sc0,0	
	strh sc0,[cpuregs,AF_reg]
	strh r0,[cpuregs,BC_reg]
	strh r0,[cpuregs,DE_reg]
	strh r0,[cpuregs,HL_reg]

	@ To be consistent with the memory viewer
	ldr sc0,=io	
	mov sc0,0x91
	strb sc0,[r0,0x40]
	mov sc0,0x81
	strb sc0,[r0,0x41]
	mov sc0,0x80
	strb sc0,[cpuregs,F_reg]
	bkpt 50
	get_op

.align 4
x00: @NOP
	get_op

.align 4
x01: @LD BC,d16 - no flags
	get_2_arg
	strh args,[cpuregs,BC_reg]
	get_op

.align 4
x02: @LD (BC),A - Load to the absolute address (BC), data from the 8-bit A register
	get_op	

.align 4
x03: @INC BC - no flags
	INC_reg16 BC_reg
	get_op

.ltorg

.align 4
x04: @INC B - z if result is 0, N is reset, H if carry from bit 3
	INC_reg8 B_reg
	get_op

.align 4
x05: @DEC B - z if result is 0, N is set, H is set if borrow from bit 4
	DEC_reg8 B_reg
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
	itte ne
	orrne sc0,1
	movne cpuflags,cflag_set
	moveq cpuflags,0
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
	ldrh sc0,[cpuregs,BC_reg]
	mem_read_rA_r16 sc0,BC_reg,sc1,sc2
	get_op

.align 4
x0b: @DEC BC - no flags
	DEC_reg16 BC_reg
	get_op

.align 4
x0c: @INC C
	INC_reg8 C_reg
	get_op

.align 4
x0d: @DEC C
	DEC_reg8 C_reg
	get_op

.align 4
x0e: @LD C,d8 - no flags
	get_1_arg
	ld_reg8_d8 C_reg
	get_op

.align 4
x0f: @RRCA - rotate right register A, include carry bit
ldrb sc0,[cpuregs,A_reg]
lsrs sc0,1
itte cs
orrcs sc0,0x80
movcs cpuflags,cflag_set
movcc cpuflags,0
strb sc0,[cpuregs,A_reg]
get_op

.align 4
x10: @STOP 0 - clock, oscillator, lcd controller are stopped, cancelled by reset signal
	bkpt 99
stoplbl:
	b stoplbl

.align 4
x11: @LD DE, d16
	get_2_arg		
	strh args,[cpuregs,DE_reg]
	get_op
 
.align 4
x12: @LD (DE),A
	get_op
	 
.align 4
x13: @INC DE
	INC_reg16 DE_reg
	get_op
	 
.align 4
x14: @INC D
	INC_reg8 D_reg
	get_op
	 
.align 4
x15: @DEC D
	DEC_reg8 D_reg
	get_op
	 
.align 4
x16: @LD D,d8
	get_1_arg
	ld_reg8_d8 D_reg
	get_op
	 
.align 4
x17: @RLA - left rotate A through the carry flag
	ldrb sc0,[cpuregs,A_reg]
	lsl sc0,1
	tst cpuflags,cflag_set
	it ne
	orrne sc0,1
	tst sc0,0x100
	ite ne
	orrne cpuflags,cflag_set
	moveq cpuflags,0
	strb sc0,[cpuregs,A_reg]
	get_op
	 
.align 4
x18: @JR r8
	get_1_arg_signed
	add progc,args
	get_op
	 
.align 4
x19: @ADD HL,DE
	 
.align 4
x1a: @LD A,(DE)
	get_op

.align 4
x1b: @DEC DE
	DEC_reg16 DE_reg
	get_op
	 
.align 4
x1c: @INC E
	INC_reg8 E_reg
	get_op

.align 4
x1d: @DEC E
	DEC_reg8 E_reg
	get_op
	 
.align 4
x1e: @LD E,d8
	get_1_arg
	ld_reg8_d8 E_reg
	get_op
	 
.align 4
x1f: @RRA
	ldrb sc0,[cpuregs,A_reg]
	tst cpuflags,cflag_set
	it ne
	orrne sc0,0x100
	lsrs sc0,1
	ite cs
	movcs cpuflags,cflag_set
	movcc cpuflags,0
	strb sc0,[cpuregs,A_reg]
	get_op

.align 4
x20: @JR NZ,s8 - jump to (PC + s8) if Zero flag is reset - s8 is SIGNED
	get_1_arg_signed
	tst cpuflags,zflag_set
	it eq
	addeq progc,args
	get_op

.align 4
x21: @LD HL,d16 - no flags
	get_2_arg
	strh args,[cpuregs,HL_reg]
	get_op

.align 4
x22: @LD (HL+),A - Same as LD (HL),A - INC HL
	get_op

   
.align 4
x23: @INC HL
	INC_reg16 HL_reg
	get_op
	 
.align 4
x24: @INC H
	INC_reg8 H_reg
	get_op
	 
.align 4
x25: @DEC H
	DEC_reg8 H_reg
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
	get_1_arg_signed
	tst cpuflags,zflag_set
	it ne
	addne progc,args
	get_op
	 
.align 4
x29: @ADD HL,HL

.align 4
x2a: @LD A,(HL+)
	get_op
	 
.align 4
x2b: @DEC HL
	DEC_reg16 HL_reg
	get_op
	 
.align 4
x2c: @INC L
	INC_reg8 L_reg
	get_op
	 
.align 4
x2d: @DEC L
	DEC_reg8 L_reg
	get_op
	 
.align 4
x2e: @LD L,d8
	get_1_arg
	ld_reg8_d8 L_reg
	get_op
	 
.align 4
x2f: @CPL
	ldrb sc0,[cpuregs,A_reg]
	eors sc0,0xff
	strb sc0,[cpuregs,A_reg]
	orr cpuflags,(nflag_set | hflag_set)
	get_op
	 
.align 4
x30: @JR NC,r8
	get_1_arg_signed
	tst cpuflags,cflag_set
	it eq
	addeq progc,args
	get_op
	 
.align 4
x31: @LD sp,d16 - load immediate into stack pointer
	@This needs a mem catch - I cant really assume the stack is going to be in wram
	get_2_arg
	sub args,0xc000 @need to subtract c000 because GBC I need the offset into wram
	cmp args,0x1000
	it mi
	addmi stackptr,sc0,cartaddr
   	get_op	

.align 4
x32: @LD (HL-),A
	get_op

	 
.align 4
x33: @INC SP
	add stackptr,1
	get_op
	 
.align 4
x34: @INC (HL)

	 
.align 4
x35: @DEC (HL)

	 
.align 4
x36: @LD (HL),d8
	get_op

.align 4
x37: @SCF - Set the carry flag
	and cpuflags,(hflag_clear & hflag_clear)
	orr cpuflags,cflag_set
	get_op
	 
.align 4
x38: @JR C,r8
	get_1_arg_signed
	tst cpuflags,cflag_set
	it ne
	addne progc,args
	get_op
	 
.align 4
x39: @ADD HL,SP

	 
.align 4
x3a: @LD A,(HL-)
	get_op

.ltorg
	 
.align 4
x3b: @DEC SP
	sub stackptr,1
	get_op
	 
.align 4
x3c: @INC A
	INC_reg8 A_reg
	get_op

.align 4
x3d: @DEC A
	DEC_reg8 A_reg
	get_op
	 
.align 4
x3e: @LD A,d8 - No flags affected 
	get_1_arg
	ld_reg8_d8 A_reg
	get_op
	 
.align 4
x3f: @CCF - complement carry flag, z left alone, nh cleared, c flipped
	and cpuflags,~(hflag_set | nflag_set)
	eor cpuflags,cflag_set
	get_op
	 
.align 4
x40: @LD B,B
	get_op
	 
.align 4
x41: @LD B,C
	ld_reg8_reg8 B_reg,C_reg
	get_op
	 
.align 4
x42: @LD B,D
	ld_reg8_reg8 B_reg,D_reg
	get_op
	 
.align 4
x43: @LD B,E
	ld_reg8_reg8 B_reg,E_reg
	get_op
	 
.align 4
x44: @LD B,H
	ld_reg8_reg8 B_reg,H_reg
	get_op
	 
.align 4
x45: @LD B,L
	ld_reg8_reg8 B_reg,L_reg
	get_op
	 
.align 4
x46: @LD B,(HL)
	get_op
	 
.align 4
x47: @LD B,A
	ld_reg8_reg8 B_reg,A_reg
	get_op
	 
.align 4
x48: @LD C,B
	ld_reg8_reg8 C_reg,B_reg
	get_op
	 
.align 4
x49: @LD C,C
	get_op
	 
.align 4
x4a: @LD C,D
	ld_reg8_reg8 C_reg,D_reg
	get_op
	 
.align 4
x4b: @LD C,E
	ld_reg8_reg8 C_reg,E_reg
	get_op
	 
.align 4
x4c: @LD C,H
	ld_reg8_reg8 C_reg,H_reg
	get_op
	 
.align 4
x4d: @LD C,L
	ld_reg8_reg8 C_reg,L_reg
	get_op
	 
.align 4
x4e: @LD C,(HL)
	get_op
	 
.align 4
x4f: @LD C,A
	ld_reg8_reg8 C_reg,A_reg
	get_op
	 
.align 4
x50: @LD D,B
	ld_reg8_reg8 D_reg,B_reg
	get_op
	 
.align 4
x51: @LD D,C
	ld_reg8_reg8 D_reg,C_reg
	get_op
	 
.align 4
x52: @LD D,D
	get_op
	 
.align 4
x53: @LD D,E
	ld_reg8_reg8 D_reg,E_reg
	get_op
	 
.align 4
x54: @LD D,H
	ld_reg8_reg8 D_reg,H_reg
	get_op
	 
.align 4
x55: @LD D,L
	ld_reg8_reg8 D_reg,L_reg
	get_op
	 
.align 4
x56: @LD D,(HL)
	get_op
	 
.align 4
x57: @LD D,A
	ld_reg8_reg8 D_reg,A_reg
	get_op
	 
.align 4
x58: @LD E,B
	ld_reg8_reg8 E_reg,B_reg
	get_op
	 
.align 4
x59: @LD E,C
	ld_reg8_reg8 E_reg,C_reg
	get_op
	 
.align 4
x5a: @LD E,D
	ld_reg8_reg8 E_reg,D_reg
	get_op
	 
.align 4
x5b: @LD E,E
	get_op
	 
.align 4
x5c: @LD E,H
	ld_reg8_reg8 E_reg,H_reg
	get_op
	 
.align 4
x5d: @LD E,L
	ld_reg8_reg8 E_reg,L_reg
	get_op
	 
.align 4
x5e: @LD E,(HL)
	get_op
	 
.align 4
x5f: @LD E,A
	ld_reg8_reg8 E_reg,A_reg
	get_op
	 
.align 4
x60: @LD H,B
	ld_reg8_reg8 H_reg,B_reg
	get_op
	 
.align 4
x61: @LD H,C
	ld_reg8_reg8 H_reg,C_reg
	get_op
	 
.align 4
x62: @LD H,D
	ld_reg8_reg8 H_reg,D_reg
	get_op
	 
.align 4
x63: @LD H,E
	ld_reg8_reg8 H_reg,E_reg
	get_op
	 
.align 4
x64: @LD H,H
	get_op
	 
.align 4
x65: @LD H,L
	ld_reg8_reg8 H_reg,L_reg
	get_op
	 
.align 4
x66: @LD H,(HL)
	get_op
	 
.align 4
x67: @LD H,A
	ld_reg8_reg8 H_reg,A_reg
	get_op
	 
.align 4
x68: @LD L,B
	ld_reg8_reg8 L_reg,B_reg
	get_op
	 
.align 4
x69: @LD L,C
	ld_reg8_reg8 L_reg,C_reg
	get_op
	 
.align 4
x6a: @LD L,D
	ld_reg8_reg8 L_reg,D_reg
	get_op
	 
.align 4
x6b: @LD L,E
	ld_reg8_reg8 L_reg,E_reg
	get_op
	 
.align 4
x6c: @LD L,H
	ld_reg8_reg8 L_reg,H_reg
	get_op
	 
.align 4
x6d: @LD L,L
	get_op
	 
.align 4
x6e: @LD L,(HL)
	get_op

.align 4
x6f: @LD L,A
	ld_reg8_reg8 L_reg,A_reg
	get_op
	 

.align 4
x70: @LD (HL),B
	get_op
	
.ltorg
	
.align 4
x71: @LD (HL),C
	get_op
	 
.ltorg

.align 4
x72: @LD (HL),D
	get_op
	 


.align 4
x73: @LD (HL),E
	get_op

.ltorg 

.align 4
x74: @LD (HL),H
	get_op
 
.ltorg

.align 4
x75: @LD (HL),L
	get_op
	 
.ltorg

.align 4
x76: @HALT - clock stopped, oscillator and lcd controller keep going. cancelled by interrupt or reset signal
	@wait for interrupts
	get_op
	 
.ltorg

.align 4
x77: @LD (HL),A
	get_op


.ltorg
	 
.align 4
x78: @LD A,B
	ld_reg8_reg8 A_reg,B_reg
	get_op
	 
.align 4
x79: @LD A,C - no flags
	ld_reg8_reg8 A_reg,C_reg
	get_op
	 
.align 4
x7a: @LD A,D
	ld_reg8_reg8 A_reg,D_reg
	get_op
	 
.align 4
x7b: @LD A,E
	ld_reg8_reg8 A_reg,E_reg
	get_op
	 
.align 4
x7c: @LD A,H
	ld_reg8_reg8 A_reg,H_reg
	get_op
	 
.align 4
x7d: @LD A,L
	ld_reg8_reg8 A_reg,L_reg
	get_op
	 
.align 4
x7e: @LD A,(HL)
	get_op
	 
.align 4
x7f: @LD A,A
	get_op
	 
.align 4
x80: @ADD A,B
	ADD_reg_reg A_reg,B_reg
	get_op
	 
.align 4
x81: @ADD A,C
	ADD_reg_reg A_reg,C_reg
	get_op
	 
.align 4
x82: @ADD A,D
	ADD_reg_reg A_reg,D_reg
	get_op
	 
.align 4
x83: @ADD A,E
	ADD_reg_reg A_reg,E_reg
	get_op
	 
.align 4
x84: @ADD A,H
	ADD_reg_reg A_reg,H_reg
	get_op
	 
.align 4
x85: @ADD A,L
	ADD_reg_reg A_reg,L_reg
	get_op
	 
.align 4
x86: @ADD A,(HL)

	 
.align 4
x87: @ADD A,A
	ADD_regA
	get_op
	 
.align 4
x88: @ADC A,B
	ADC_reg_reg A_reg,B_reg
	get_op
	 
.align 4
x89: @ADC A,C
	ADC_reg_reg A_reg,C_reg
	get_op
	 
.align 4
x8a: @ADC A,D
	ADC_reg_reg A_reg,D_reg
	get_op
	 
.align 4
x8b: @ADC A,E
	ADC_reg_reg A_reg,E_reg
	get_op
	 
.align 4
x8c: @ADC A,H
	ADC_reg_reg A_reg,H_reg
	get_op
	 
.align 4
x8d: @ADC A,L
	ADC_reg_reg A_reg,L_reg
	get_op
	 
.align 4
x8e: @ADC A,(HL)

	 
.align 4
x8f: @ADC A,A
	ADC_regA
	get_op
	 
.align 4
x90: @SUB B
	SUB_reg B_reg
	get_op 

.align 4
x91: @SUB C
	SUB_reg C_reg
	get_op 
	 
.align 4
x92: @SUB D
	SUB_reg D_reg
	get_op 
	 
.align 4
x93: @SUB E
	SUB_reg E_reg
	get_op 
	 
.align 4
x94: @SUB H
	SUB_reg H_reg
	get_op 
	 
.align 4
x95: @SUB L
	SUB_reg L_reg
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
	SBC_reg B_reg
	get_op 
	 
.align 4
x99: @SBC A,C
	SBC_reg C_reg
	get_op 
	 
.align 4
x9a: @SBC A,D
	SBC_reg D_reg
	get_op 
	 
.align 4
x9b: @SBC A,E
	SBC_reg E_reg
	get_op 
	 
.align 4
x9c: @SBC A,H
	SBC_reg H_reg
	get_op 
	 
.align 4
x9d: @SBC A,L
	SBC_reg L_reg
	get_op 
	 
.align 4
x9e: @SBC A,(HL)
	get_op
	 
.align 4
x9f: @SBC A,A
	tst cpuflags,cflag_set
	ittee eq
	moveq sc0,0xff
	moveq cpuflags,0x70  @Z=0; H,C,N = 1
	movne sc0,0
	movne cpuflags,0xc0	@Z,N = 1; H,C = 0
	strb sc0,[cpuregs,A_reg]
	get_op
	 
.align 4
xa0: @AND B
	AND_reg B_reg
	get_op
	 
.align 4
xa1: @AND C
	AND_reg C_reg
	get_op
	 
.align 4
xa2: @AND D
	AND_reg D_reg
	get_op
	 
.align 4
xa3: @AND E
	AND_reg E_reg
	get_op
	 
.align 4
xa4: @AND H
	AND_reg H_reg
	get_op
	 
.align 4
xa5: @AND L
	AND_reg L_reg
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
	XOR_reg B_reg
	get_op
	 
.align 4
xa9: @XOR C
	XOR_reg C_reg
	get_op

	 
.align 4
xaa: @XOR D
	XOR_reg D_reg
	get_op

	 
.align 4
xab: @XOR E
	XOR_reg E_reg
	get_op

	 
.align 4
xac: @XOR H
	XOR_reg H_reg
	get_op

	 
.align 4
xad: @XOR L
	XOR_reg L_reg
	get_op

	 
.align 4
xae: @XOR (HL)

	 
.align 4
xaf: @XOR A @ just set A to zero and set the z flag
	mov sc0,0
	strb sc0,[cpuregs,A_reg]
	mov cpuflags,zflag_set
	get_op
	 
.align 4
xb0: @OR B
	OR_reg B_reg
	get_op
	 
.align 4
xb1: @OR C
	OR_reg C_reg
	get_op

.align 4
xb2: @OR D
	OR_reg D_reg
	get_op
	 
.align 4
xb3: @OR E
	OR_reg E_reg
	get_op
	 
.align 4
xb4: @OR H
	OR_reg H_reg
	get_op
	 
.align 4
xb5: @OR L
	OR_reg L_reg
	get_op
	 
.align 4
xb6: @OR (HL)

.align 4
xb7: @OR A
	OR_reg A_reg
	get_op
	 
.align 4
xb8: @CP B
	CP_reg B_reg
	get_op
	 
.align 4
xb9: @CP C
	CP_reg C_reg
	get_op
	 
.align 4
xba: @CP D
	CP_reg D_reg
	get_op
	 
.align 4
xbb: @CP E
	CP_reg E_reg
	get_op
	 
.align 4
xbc: @CP H
	CP_reg H_reg
	get_op
	 
.align 4
xbd: @CP L
	CP_reg L_reg
	get_op
	 
.align 4
xbe: @CP (HL)

	 
.align 4
xbf: @CP A - I feel like this is too easy, CP A is always going to be 0
	mov cpuflags,0xc0
	get_op
	 
.align 4
xc0: @RET NZ
	tst cpuflags,zflag_set
	itt ne
	get_opne
	RET_POP
	get_op
	 
.align 4
xc1: @POP BC
	POP_reg16 BC_reg
	get_op
	 
.align 4
xc2: @JP NZ,a16
	get_2_arg
	tst cpuflags,zflag_set
	it eq			
	addeq progc,args,cartaddr
	get_op

.align 4
xc3: @JP a16
	get_2_arg
	add progc,args,cartaddr
	get_op

.align 4
xc4: @CALL NZ,a16
	get_2_arg
	tst cpuflags,zflag_set
	itt ne
	get_opne
	CALL_PUSH
	add progc,args,cartaddr
	get_op 
	 
.align 4
xc5: @PUSH BC
	PUSH_reg16 BC_reg
	get_op
	 
.align 4
xc6: @ADD A,d8
	get_1_arg
	ldrb sc0,[cpuregs,A_reg]
	mov sc2,sc0					@ sc2 holds the pre-op value of A_reg
	add sc0,args				@ sc0 holds the post-op value
	strb sc0,[cpuregs,A_reg]
	tst sc0,0x100				@ cflag
	set_c_eq
	tst sc0,0xff				@ zflag
	set_z_eq
	and sc2,0xf					@ hflag
	and args,0xf
	add sc2,args
	tst sc2, 0x10
	set_h_eq
	clear_nflag
	get_op
	 
.align 4
xc7: @RST 00H

	 
.align 4
xc8: @RET Z
	tst cpuflags,zflag_set
	itt eq
	get_opeq
	RET_POP
	get_op
	 
.align 4
xc9: @RET
	RET_POP
	get_op
	 
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
	get_2_arg
	tst cpuflags,zflag_set
	itt eq
	get_opeq
	CALL_PUSH
	add progc,args,cartaddr
	get_op 

.align 4
xcd: @CALL a16 - push addr of next instruction to stack and jump to a16
	get_2_arg
	CALL_PUSH
	add progc,args,cartaddr
	get_op
	 
.align 4
xce: @ADC A,d8
	get_1_arg
	ldrb sc0,[cpuregs,A_reg]
	mov sc2,sc0					@ sc2 holds the pre-op value of A_reg
	add sc0,args				@ sc0 holds the post-op value
	tst cpuflags,cflag_set
	it eq
	addeq sc0,1
	strb sc0,[cpuregs,A_reg]
	tst sc0,0x100				@ cflag
	set_c_eq
	tst sc0,0xff				@ zflag
	set_z_eq
	and sc2,0xf					@ hflag
	and args,0xf
	add sc2,args
	tst sc2, 0x10
	set_h_eq
	clear_nflag
	get_op
	 
.align 4
xcf: @RST 08H

	 
.align 4
xd0: @RET NC
	tst cpuflags,cflag_set
	itt ne
	get_opne
	RET_POP
	get_op
	 
.align 4
xd1: @POP DE
	POP_reg16 DE_reg
	get_op
	 
.align 4
xd2: @JP NC,a16
	get_2_arg
	tst cpuflags,cflag_set
	it eq			
	addeq progc,args,cartaddr
	get_op
	 
.align 4
xd3: @unused - USED FOR TIMING TESTS

	 
.align 4
xd4: @CALL NC,a16
	get_2_arg
	tst cpuflags,cflag_set
	itt ne
	get_opne
	CALL_PUSH
	add progc,args,cartaddr
	get_op 
	 
.align 4
xd5: @PUSH DE
	PUSH_reg16 DE_reg
	get_op
	 
.align 4
xd6: @SUB d8
	get_1_arg
	ldrb sc0,[cpuregs,A_reg]
	mov sc1,sc0
	subs sc0,args
	strb sc0,[cpuregs,A_reg]
	set_z_eq
	ite mi							@ if the result is negative, this will be true (a borrow happened)
	andmi cpuflags,cflag_clear		@ the cflag is cleared if a borrow occurred
	orrpl cpuflags,cflag_set		@ the cflag is set if a borrow did not occur	
	and sc1,0xf						@ hflag
	and args,0xf
	cmp sc1,args
	ite mi
	andmi cpuflags,hflag_clear
	orrpl cpuflags,hflag_set
	set_nflag
	 
.align 4
xd7: @RST 10H

	 
.align 4
xd8: @RET C
	tst cpuflags,cflag_set
	itt eq
	get_opeq
	RET_POP
	get_op
	 
.align 4
xd9: @RETI - used when an interrupt is exited. Returns interrupt enable flag to previous state
	@ conditionally re-enable interrupt flag
	RET_POP
	get_op
	 
.align 4
xda: @JP C,a16
	get_2_arg
	tst cpuflags,cflag_set
	it ne			
	addne progc,args,cartaddr
	get_op
	 
.align 4
xdb: @unused
	 
.align 4
xdc: @CALL C,a16
	get_2_arg
	tst cpuflags,cflag_set
	itt eq
	get_opeq
	CALL_PUSH
	add progc,args,cartaddr
	get_op 
	 
.align 4
xdd:@unused
	 
.align 4
xde: @SBC A,d8
	get_1_arg
	ldrb sc0,[cpuregs,A_reg]
	mov sc1,sc0
	tst cpuflags,cflag_set
	it eq
	subeq sc0,1
	subs sc0,args							@ do this subtraction last so I can use it to set flags
	strb sc0,[cpuregs,A_reg]
	set_z_eq
	ite mi									@ if the result is negative, this will be true (a borrow happened)
	andmi cpuflags,cflag_clear				@ the cflag is cleared if a borrow occurred
	orrpl cpuflags,cflag_set				@ the cflag is set if a borrow did not occur
	and sc1,sc1,0xf							@ hflag
	and args,args,0xf
	cmp sc1,args
	ite mi
	andmi cpuflags,hflag_clear
	orrpl cpuflags,hflag_set
	set_nflag
	 
.align 4
xdf: @RST 18H

	 
.align 4
xe0: @LDH (a8),A

	 
.align 4
xe1: @POP HL
	POP_reg16 HL_reg
	get_op
	 
.align 4
xe2: @LD (C),A - write to IO port at address (0xFF00 + (C)) the contents of A

	 
.align 4
xe3:@unused
	 
.align 4
xe4:@unused
	 
.align 4
xe5: @PUSH HL
	PUSH_reg16 HL_reg
	get_op
	 
.align 4
xe6: @AND d8 - Z is set if AND is 0, N is reset, H is set, C is reset
	get_1_arg
	ldrb sc0,[cpuregs,A_reg]
	ands sc0,args
	strb sc0,[cpuregs,A_reg]
	ite eq
	moveq cpuflags,(zflag_set | hflag_set)
	movne cpuflags,hflag_set
	get_op
	
.align 4
xe7: @RST 20H

	 
.align 4
xe8: @ADD SP,r8
	
	 
.align 4
xe9: @JP HL
	ldrh sc0,[cpuregs,HL_reg]
	add progc,cartaddr,sc0
	get_op
	 
.align 4
xea: @LD (a16),A - put A into address (a16) addr fix
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
	get_1_arg
	ldrb sc0,[cpuregs,A_reg]
	eors sc0,args
	strb sc0,[cpuregs,A_reg]
	ite eq
	moveq cpuflags,zflag_set
	movne cpuflags,0
	get_op
	 
.align 4
xef: @RST 28H

	 
.align 4
xf0: @LDH A,(a8) - store the address (0xFF00 + a8) into A - I/O DATA

.align 4
xf1: @POP AF
	POP_reg16 AF_reg
	get_op
	 
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
	PUSH_reg16 AF_reg
	get_op
	 
.align 4
xf6: @OR d8
	get_1_arg
	ldrb sc0,[cpuregs,A_reg]
	orrs sc0,args
	strb sc0,[cpuregs,A_reg]
	ite eq
	moveq cpuflags,zflag_set
	movne cpuflags,0
	get_op
	 
.align 4
xf7: @RST 30H

	 
.align 4
xf8: @LD HL,SP+r8

	 
.align 4
xf9: @LD SP,HL

	 
.align 4
xfa: @LD A,(a16)
	get_op
	 
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
	cb_rlc_r8 B_reg
	get_op

.align 4
cb01: @RLC,C
	cb_rlc_r8 C_reg
	get_op

.align 4
cb02: @RLC,D
	cb_rlc_r8 D_reg
	get_op

.align 4
cb03: @RLC,E
	cb_rlc_r8 E_reg
	get_op

.align 4
cb04: @RLC,H
	cb_rlc_r8 H_reg
	get_op

.align 4
cb05: @RLC,L
	cb_rlc_r8 L_reg
	get_op

.align 4
cb06: @RLC,(HL)


.align 4
cb07: @RLC,A
	cb_rlc_r8 A_reg
	get_op

.align 4
cb08: @RRC,B
	cb_rrc_r8 B_reg
	get_op

.align 4
cb09: @RRC,C
	cb_rrc_r8 C_reg
	get_op

.align 4
cb0a: @RRC,D
	cb_rrc_r8 D_reg
	get_op

.align 4
cb0b: @RRC,E
	cb_rrc_r8 E_reg
	get_op

.align 4
cb0c: @RRC,H
	cb_rrc_r8 H_reg
	get_op

.align 4
cb0d: @RRC,L
	cb_rrc_r8 L_reg
	get_op

.align 4
cb0e: @RRC,(HL)


.align 4
cb0f: @RRC,A
	cb_rrc_r8 A_reg
	get_op

.align 4
cb10: @RL,B
	cb_rl_r8 B_reg
	get_op

.align 4
cb11: @RL,C
	cb_rl_r8 C_reg
	get_op

.align 4
cb12: @RL,D
	cb_rl_r8 D_reg
	get_op

.align 4
cb13: @RL,E
	cb_rl_r8 E_reg
	get_op

.align 4
cb14: @RL,H
	cb_rl_r8 H_reg
	get_op

.align 4
cb15: @RL,L
	cb_rl_r8 L_reg
	get_op

.align 4
cb16: @RL,(HL)


.align 4
cb17: @RL,A
	cb_rl_r8 A_reg
	get_op

.align 4
cb18: @RR,B
	cb_rr_r8 B_reg
	get_op

.align 4
cb19: @RR,C
	cb_rr_r8 C_reg
	get_op

.align 4
cb1a: @RR,D
	cb_rr_r8 D_reg
	get_op

.align 4
cb1b: @RR,E
	cb_rr_r8 E_reg
	get_op

.align 4
cb1c: @RR,H
	cb_rr_r8 H_reg
	get_op

.align 4
cb1d: @RR,L
	cb_rr_r8 L_reg
	get_op

.align 4
cb1e: @RR,(HL)


.align 4
cb1f: @RR,A
	cb_rr_r8 A_reg
	get_op

.align 4
cb20: @SLA,B
	cb_sla_r8 B_reg
	get_op

.align 4
cb21: @SLA,C
	cb_sla_r8 C_reg
	get_op

.align 4
cb22: @SLA,D
	cb_sla_r8 D_reg
	get_op

.align 4
cb23: @SLA,E
	cb_sla_r8 E_reg
	get_op

.align 4
cb24: @SLA,H
	cb_sla_r8 H_reg
	get_op

.align 4
cb25: @SLA,L
	cb_sla_r8 L_reg
	get_op

.align 4
cb26: @SLA,(HL)


.align 4
cb27: @SLA,A
	cb_sla_r8 A_reg
	get_op

.align 4
cb28: @SRA,B
	cb_sra_r8 B_reg
	get_op

.align 4
cb29: @SRA,C
	cb_sra_r8 C_reg
	get_op

.align 4
cb2a: @SRA,D
	cb_sra_r8 D_reg
	get_op

.align 4
cb2b: @SRA,E
	cb_sra_r8 E_reg
	get_op

.align 4
cb2c: @SRA,H
	cb_sra_r8 H_reg
	get_op

.align 4
cb2d: @SRA,L
	cb_sra_r8 L_reg
	get_op

.align 4
cb2e: @SRA,(HL)


.align 4
cb2f: @SRA,A
	cb_sra_r8 A_reg
	get_op

.align 4
cb30: @SWAP B - set z conditionally, N,H,C cleared
	cb_swap_r8 B_reg
	get_op

.align 4
cb31: @SWAP C
	cb_swap_r8 C_reg
	get_op

.align 4
cb32: @SWAP D
	cb_swap_r8 D_reg
	get_op

.align 4
cb33: @SWAP E
	cb_swap_r8 E_reg
	get_op

.align 4
cb34: @SWAP H
	cb_swap_r8 H_reg
	get_op

.align 4
cb35: @SWAP L
	cb_swap_r8 L_reg
	get_op

.align 4
cb36: @SWAP (HL)
	get_op

.align 4
cb37: @SWAP A
	cb_swap_r8 A_reg
	get_op

.align 4
cb38: @SRL,B
	cb_srl_r8 B_reg
	get_op

.align 4
cb39: @SRL,C
	cb_srl_r8 C_reg
	get_op

.align 4
cb3a: @SRL,D
	cb_srl_r8 D_reg
	get_op

.align 4
cb3b: @SRL,E
	cb_srl_r8 E_reg
	get_op

.align 4
cb3c: @SRL,H
	cb_srl_r8 H_reg
	get_op

.align 4
cb3d: @SRL,L
	cb_srl_r8 L_reg
	get_op

.align 4
cb3e: @SRL,(HL)


.align 4
cb3f: @SRL,A
	cb_srl_r8 A_reg
	get_op

.align 4
cb40: @BIT 0,B
	cb_bit 0,B_reg
	get_op

.align 4
cb41: @BIT 0,C
	cb_bit 0,C_reg
	get_op

.align 4
cb42: @BIT 0,D
	cb_bit 0,D_reg
	get_op

.align 4
cb43: @BIT 0,E
	cb_bit 0,E_reg
	get_op

.align 4
cb44: @BIT 0,H
	cb_bit 0,H_reg
	get_op

.align 4
cb45: @BIT 0,L
	cb_bit 0,L_reg
	get_op

.align 4
cb46: @BIT 0,(HL)

.align 4
cb47: @BIT 0,A
	cb_bit 0,A_reg
	get_op

.align 4
cb48: @BIT 1,B
	cb_bit 1,B_reg
	get_op

.align 4
cb49: @BIT 1,C
	cb_bit 1,C_reg
	get_op

.align 4
cb4a: @BIT 1,D
	cb_bit 1,D_reg
	get_op

.align 4
cb4b: @BIT 1,E
	cb_bit 1,E_reg
	get_op

.align 4
cb4c: @BIT 1,H
	cb_bit 1,H_reg
	get_op

.align 4
cb4d: @BIT 1,L
	cb_bit 1,L_reg
	get_op

.align 4
cb4e: @BIT 1,(HL)


.align 4
cb4f: @BIT 1,A
	cb_bit 1,A_reg
	get_op

.align 4
cb50: @BIT 2,B
	cb_bit 2,B_reg
	get_op

.align 4
cb51: @BIT 2,C
	cb_bit 2,C_reg
	get_op

.align 4
cb52: @BIT 2,D
	cb_bit 2,D_reg
	get_op

.align 4
cb53: @BIT 2,E
	cb_bit 2,E_reg
	get_op

.align 4
cb54: @BIT 2,H
	cb_bit 2,H_reg
	get_op

.align 4
cb55: @BIT 2,L
	cb_bit 2,L_reg
	get_op

.align 4
cb56: @BIT 2,(HL)


.align 4
cb57: @BIT 2,A
	cb_bit 2,A_reg
	get_op

.align 4
cb58: @BIT 3,B
	cb_bit 3,B_reg
	get_op

.align 4
cb59: @BIT 3,C
	cb_bit 3,C_reg
	get_op

.align 4
cb5a: @BIT 3,D
	cb_bit 3,D_reg
	get_op

.align 4
cb5b: @BIT 3,E
	cb_bit 3,E_reg
	get_op

.align 4
cb5c: @BIT 3,H
	cb_bit 3,H_reg
	get_op

.align 4
cb5d: @BIT 3,L
	cb_bit 3,L_reg
	get_op

.align 4
cb5e: @BIT 3,(HL)


.align 4
cb5f: @BIT 3,A
	cb_bit 3,A_reg
	get_op

.align 4
cb60: @BIT 4,B
	cb_bit 4,B_reg
	get_op

.align 4
cb61: @BIT 4,C
	cb_bit 4,C_reg
	get_op

.align 4
cb62: @BIT 4,D
	cb_bit 4,D_reg
	get_op

.align 4
cb63: @BIT 4,E
	cb_bit 4,E_reg
	get_op

.align 4
cb64: @BIT 4,H
	cb_bit 4,H_reg
	get_op

.align 4
cb65: @BIT 4,L
	cb_bit 4,L_reg
	get_op

.align 4
cb66: @BIT 4,(HL)


.align 4
cb67: @BIT 4,A
	cb_bit 4,A_reg
	get_op

.align 4
cb68: @BIT 5,B
	cb_bit 5,B_reg
	get_op

.align 4
cb69: @BIT 5,C
	cb_bit 5,C_reg
	get_op

.align 4
cb6a: @BIT 5,D
	cb_bit 5,D_reg
	get_op

.align 4
cb6b: @BIT 5,E
	cb_bit 5,E_reg
	get_op

.align 4
cb6c: @BIT 5,H
	cb_bit 5,H_reg
	get_op

.align 4
cb6d: @BIT 5,L
	cb_bit 5,L_reg
	get_op

.align 4
cb6e: @BIT 5,(HL)


.align 4
cb6f: @BIT 5,A
	cb_bit 5,A_reg
	get_op

.align 4
cb70: @BIT 6,B
	cb_bit 6,B_reg
	get_op

.align 4
cb71: @BIT 6,C
	cb_bit 6,C_reg
	get_op

.align 4
cb72: @BIT 6,D
	cb_bit 6,D_reg
	get_op

.align 4
cb73: @BIT 6,E
	cb_bit 6,E_reg
	get_op

.align 4
cb74: @BIT 6,H
	cb_bit 6,H_reg
	get_op

.align 4
cb75: @BIT 6,L
	cb_bit 6,L_reg
	get_op

.align 4
cb76: @BIT 6,(HL)


.align 4
cb77: @BIT 6,A
	cb_bit 6,A_reg
	get_op

.align 4
cb78: @BIT 7,B
	cb_bit 7,B_reg
	get_op

.align 4
cb79: @BIT 7,C
	cb_bit 7,C_reg
	get_op

.align 4
cb7a: @BIT 7,D
	cb_bit 7,D_reg
	get_op

.align 4
cb7b: @BIT 7,E
	cb_bit 7,E_reg
	get_op

.align 4
cb7c: @BIT 7,H
	cb_bit 7,H_reg
	get_op

.align 4
cb7d: @BIT 7,L
	cb_bit 7,L_reg
	get_op

.align 4
cb7e: @BIT 7,(HL)


.align 4
cb7f: @BIT 7,A
	cb_bit 7,A_reg
	get_op


.align 4
cb80: @RES 0,B
	cb_reset_bit 0,B_reg
	get_op

.align 4
cb81: @RES 0,C
	cb_reset_bit 0,C_reg
	get_op

.align 4
cb82: @RES 0,D
	cb_reset_bit 0,D_reg
	get_op

.align 4
cb83: @RES 0,E
	cb_reset_bit 0,E_reg
	get_op

.align 4
cb84: @RES 0,H
	cb_reset_bit 0,H_reg
	get_op

.align 4
cb85: @RES 0,L
	cb_reset_bit 0,L_reg
	get_op

.align 4
cb86: @RES 0,(HL)


.align 4
cb87: @RES 0,A
	cb_reset_bit 0,A_reg
	get_op

.align 4
cb88: @RES 1,B
	cb_reset_bit 1,B_reg
	get_op

.align 4
cb89: @RES 1,C
	cb_reset_bit 1,C_reg
	get_op

.align 4
cb8a: @RES 1,D
	cb_reset_bit 1,D_reg
	get_op

.align 4
cb8b: @RES 1,E
	cb_reset_bit 1,E_reg
	get_op

.align 4
cb8c: @RES 1,H
	cb_reset_bit 1,H_reg
	get_op

.align 4
cb8d: @RES 1,L
	cb_reset_bit 1,L_reg
	get_op

.align 4
cb8e: @RES 1,(HL)


.align 4
cb8f: @RES 1,A
	cb_reset_bit 1,A_reg
	get_op

.align 4
cb90: @RES 2,B
	cb_reset_bit 2,B_reg
	get_op

.align 4
cb91: @RES 2,C
	cb_reset_bit 2,C_reg
	get_op

.align 4
cb92: @RES 2,D
	cb_reset_bit 2,D_reg
	get_op

.align 4
cb93: @RES 2,E
	cb_reset_bit 2,E_reg
	get_op

.align 4
cb94: @RES 2,H
	cb_reset_bit 2,H_reg
	get_op

.align 4
cb95: @RES 2,L
	cb_reset_bit 2,L_reg
	get_op

.align 4
cb96: @RES 2,(HL)


.align 4
cb97: @RES 2,A
	cb_reset_bit 2,A_reg
	get_op

.align 4
cb98: @RES 3,B
	cb_reset_bit 3,B_reg
	get_op

.align 4
cb99: @RES 3,C
	cb_reset_bit 3,C_reg
	get_op

.align 4
cb9a: @RES 3,D
	cb_reset_bit 3,D_reg
	get_op

.align 4
cb9b: @RES 3,E
	cb_reset_bit 3,E_reg
	get_op

.align 4
cb9c: @RES 3,H
	cb_reset_bit 3,H_reg
	get_op

.align 4
cb9d: @RES 3,L
	cb_reset_bit 3,L_reg
	get_op

.align 4
cb9e: @RES 3,(HL)


.align 4
cb9f: @RES 3,A
	cb_reset_bit 3,A_reg
	get_op

.align 4
cba0: @RES 4,B
	cb_reset_bit 4,B_reg
	get_op

.align 4
cba1: @RES 4,C
	cb_reset_bit 4,C_reg
	get_op

.align 4
cba2: @RES 4,D
	cb_reset_bit 4,D_reg
	get_op

.align 4
cba3: @RES 4,E
	cb_reset_bit 4,E_reg
	get_op

.align 4
cba4: @RES 4,H
	cb_reset_bit 4,H_reg
	get_op

.align 4
cba5: @RES 4,L
	cb_reset_bit 4,L_reg
	get_op

.align 4
cba6: @RES 4,(HL)


.align 4
cba7: @RES 4,A
	cb_reset_bit 4,A_reg
	get_op

.align 4
cba8: @RES 5,B
	cb_reset_bit 5,B_reg
	get_op

.align 4
cba9: @RES 5,C
	cb_reset_bit 5,C_reg
	get_op

.align 4
cbaa: @RES 5,D
	cb_reset_bit 5,D_reg
	get_op

.align 4
cbab: @RES 5,E
	cb_reset_bit 5,E_reg
	get_op

.align 4
cbac: @RES 5,H
	cb_reset_bit 5,H_reg
	get_op

.align 4
cbad: @RES 5,L
	cb_reset_bit 5,L_reg
	get_op

.align 4
cbae: @RES 5,(HL)


.align 4
cbaf: @RES 5,A
	cb_reset_bit 5,A_reg
	get_op

.align 4
cbb0: @RES 6,B
	cb_reset_bit 6,B_reg
	get_op

.align 4
cbb1: @RES 6,C
	cb_reset_bit 6,C_reg
	get_op

.align 4
cbb2: @RES 6,D
	cb_reset_bit 6,D_reg
	get_op

.align 4
cbb3: @RES 6,E
	cb_reset_bit 6,E_reg
	get_op

.align 4
cbb4: @RES 6,H
	cb_reset_bit 6,H_reg
	get_op

.align 4
cbb5: @RES 6,L
	cb_reset_bit 6,L_reg
	get_op

.align 4
cbb6: @RES 6,(HL)


.align 4
cbb7: @RES 6,A
	cb_reset_bit 6,A_reg
	get_op

.align 4
cbb8: @RES 7,B
	cb_reset_bit 7,B_reg
	get_op

.align 4
cbb9: @RES 7,C
	cb_reset_bit 7,C_reg
	get_op

.align 4
cbba: @RES 7,D
	cb_reset_bit 7,D_reg
	get_op

.align 4
cbbb: @RES 7,E
	cb_reset_bit 7,E_reg
	get_op

.align 4
cbbc: @RES 7,H
	cb_reset_bit 7,H_reg
	get_op

.align 4
cbbd: @RES 7,L
	cb_reset_bit 7,L_reg
	get_op

.align 4
cbbe: @RES 7,(HL)


.align 4
cbbf: @RES 7,A
	cb_reset_bit 7,A_reg
	get_op

.align 4
cbc0: @SET 0,B
	cb_set_bit 0,B_reg
	get_op

.align 4
cbc1: @SET 0,C
	cb_set_bit 0,C_reg
	get_op

.align 4
cbc2: @SET 0,D
	cb_set_bit 0,D_reg
	get_op

.align 4
cbc3: @SET 0,E
	cb_set_bit 0,E_reg
	get_op

.align 4
cbc4: @SET 0,H
	cb_set_bit 0,H_reg
	get_op

.align 4
cbc5: @SET 0,L
	cb_set_bit 0,L_reg
	get_op

.align 4
cbc6: @SET 0,(HL)


.align 4
cbc7: @SET 0,A
	cb_set_bit 0,A_reg
	get_op

.align 4
cbc8: @SET 1,B
	cb_set_bit 1,B_reg
	get_op

.align 4
cbc9: @SET 1,C
	cb_set_bit 1,C_reg
	get_op

.align 4
cbca: @SET 1,D
	cb_set_bit 1,D_reg
	get_op

.align 4
cbcb: @SET 1,E
	cb_set_bit 1,E_reg
	get_op

.align 4
cbcc: @SET 1,H
	cb_set_bit 1,H_reg
	get_op

.align 4
cbcd: @SET 1,L
	cb_set_bit 1,L_reg
	get_op

.align 4
cbce: @SET 1,(HL)


.align 4
cbcf: @SET 1,A
	cb_set_bit 1,A_reg
	get_op

.align 4
cbd0: @SET 2,B
	cb_set_bit 2,B_reg
	get_op

.align 4
cbd1: @SET 2,C
	cb_set_bit 2,C_reg
	get_op

.align 4
cbd2: @SET 2,D
	cb_set_bit 2,D_reg
	get_op

.align 4
cbd3: @SET 2,E
	cb_set_bit 2,E_reg
	get_op

.align 4
cbd4: @SET 2,H
	cb_set_bit 2,H_reg
	get_op

.align 4
cbd5: @SET 2,L
	cb_set_bit 2,L_reg
	get_op

.align 4
cbd6: @SET 2,(HL)


.align 4
cbd7: @SET 2,A
	cb_set_bit 2,A_reg
	get_op

.align 4
cbd8: @SET 3,B
	cb_set_bit 3,B_reg
	get_op

.align 4
cbd9: @SET 3,C
	cb_set_bit 3,C_reg
	get_op

.align 4
cbda: @SET 3,D
	cb_set_bit 3,D_reg
	get_op

.align 4
cbdb: @SET 3,E
	cb_set_bit 3,E_reg
	get_op

.align 4
cbdc: @SET 3,H
	cb_set_bit 3,H_reg
	get_op

.align 4
cbdd: @SET 3,L
	cb_set_bit 3,L_reg
	get_op

.align 4
cbde: @SET 3,(HL)


.align 4
cbdf: @SET 3,A
	cb_set_bit 3,A_reg
	get_op

.align 4
cbe0: @SET 4,B
	cb_set_bit 4,B_reg
	get_op

.align 4
cbe1: @SET 4,C
	cb_set_bit 4,C_reg
	get_op

.align 4
cbe2: @SET 4,D
	cb_set_bit 4,D_reg
	get_op

.align 4
cbe3: @SET 4,E
	cb_set_bit 4,E_reg
	get_op

.align 4
cbe4: @SET 4,H
	cb_set_bit 4,H_reg
	get_op

.align 4
cbe5: @SET 4,L
	cb_set_bit 4,L_reg
	get_op

.align 4
cbe6: @SET 4,(HL)


.align 4
cbe7: @SET 4,A
	cb_set_bit 4,A_reg
	get_op

.align 4
cbe8: @SET 5,B
	cb_set_bit 5,B_reg
	get_op

.align 4
cbe9: @SET 5,C
	cb_set_bit 5,C_reg
	get_op

.align 4
cbea: @SET 5,D
	cb_set_bit 5,D_reg
	get_op

.align 4
cbeb: @SET 5,E
	cb_set_bit 5,E_reg
	get_op

.align 4
cbec: @SET 5,H
	cb_set_bit 5,H_reg
	get_op

.align 4
cbed: @SET 5,L
	cb_set_bit 5,L_reg
	get_op

.align 4
cbee: @SET 5,(HL)


.align 4
cbef: @SET 5,A
	cb_set_bit 5,A_reg
	get_op

.align 4
cbf0: @SET 6,B
	cb_set_bit 6,B_reg
	get_op

.align 4
cbf1: @SET 6,C
	cb_set_bit 6,C_reg
	get_op

.align 4
cbf2: @SET 6,D
	cb_set_bit 6,D_reg
	get_op

.align 4
cbf3: @SET 6,E
	cb_set_bit 6,E_reg
	get_op

.align 4
cbf4: @SET 6,H
	cb_set_bit 6,H_reg
	get_op

.align 4
cbf5: @SET 6,L
	cb_set_bit 6,L_reg
	get_op

.align 4
cbf6: @SET 6,(HL)


.align 4
cbf7: @SET 6,A
	cb_set_bit 6,A_reg
	get_op

.align 4
cbf8: @SET 7,B
	cb_set_bit 7,B_reg
	get_op

.align 4
cbf9: @SET 7,C
	cb_set_bit 7,C_reg
	get_op

.align 4
cbfa: @SET 7,D
	cb_set_bit 7,D_reg
	get_op

.align 4
cbfb: @SET 7,E
	cb_set_bit 7,E_reg
	get_op

.align 4
cbfc: @SET 7,H
	cb_set_bit 7,H_reg
	get_op

.align 4
cbfd: @SET 7,L
	cb_set_bit 7,L_reg
	get_op

.align 4
cbfe: @SET 7,(HL)


.align 4
cbff: @SET 7,A
	cb_set_bit 7,A_reg
	get_op



