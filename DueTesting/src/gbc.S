.syntax unified


#define debug				@This puts bkpt in get_op
@#define debug_mem_catch
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

.macro ld_A_rr, offset, rA
	@needs catch
.endm

.macro ld_ra16_d8, offset, data, rA, rB @load into (ra16) the data d8
#ifdef debug_mem_catch
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
extram: .word =0x61000000
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
	get_op

x00: @NOP
	get_op
x01: @LD BC,d16 - no flags
	get_2_arg
	ld_rr_nn BC_reg,args
	get_op

x02: @LD (BC),A - Load to the absolute address (BC), data from the 8-bit A register
	ldrb sc0,[cpuregs,A_reg]  @sc0 holds the data from A_reg
	ld_ra16_d8 BC_reg, sc0,sc1,sc2
	get_op


x03: @INC BC - no flags
	inc_reg16 sc0,BC_reg
	get_op

.ltorg

x04: @INC B - z if result is 0, N is reset, H if carry from bit 3
	inc_reg8 sc0,B_reg
	get_op

x05: @DEC B - z if result is 0, N is set, H is set if borrow from bit 4
	dec_reg8 sc0,B_reg
	get_op

x06: @LD B,d8
	get_1_arg
	ld_reg8_d8 B_reg
	get_op

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

x08: @LD (nn),SP - load to the absolute address specified by the 16-bit operand nn, data from the 16-bit SP register
	get_2_arg
	get_op

x09: @ADD HL,BC - z ignored, n cleared, h, c conditionally set.
	get_op

x0a: @LD A,(BC) - Load to the accumulator, data from the address specified by (BC)
	ld_A_rr BC_reg,sc0
	get_op

x0b: @DEC BC - no flags
	dec_reg16 sc0,BC_reg
	get_op

x0c: @INC C
	inc_reg8 sc0,C_reg
	get_op

x0d: @DEC C
	dec_reg8 sc0,C_reg
	get_op

x0e: @LD C,d8 - no flags
	get_1_arg
	ld_reg8_d8 C_reg
	get_op

x0f: @RRCA

x10: @STOP 0 - clock, oscillator, lcd controller are stopped, cancelled by reset signal
	bkpt 99
stoplbl:
	b stoplbl

x11: @LD DE, d16
	get_2_arg		
	ld_rr_nn DE_reg,args
	get_op
 
x12: @LD (DE),A
	ldrb sc0,[cpuregs,A_reg]
	ld_ra16_d8 DE_reg, sc0,sc1,sc2
	get_op
	 
x13: @INC DE
	inc_reg16 sc0, DE_reg
	get_op
	 
x14: @INC D
	inc_reg8 sc0,D_reg
	get_op
	 
x15: @DEC D
	dec_reg8 sc0,D_reg
	get_op
	 
x16: @LD D,d8
	get_1_arg
	ld_reg8_d8 D_reg
	get_op
	 
x17: @RLA
	 
x18: @JR r8
	 
x19: @ADD HL,DE
	 
x1a: @LD A,(DE)
	 
x1b: @DEC DE
	dec_reg16 sc0,DE_reg
	get_op
	 
x1c: @INC E
	inc_reg8 sc0,E_reg
	get_op

x1d: @DEC E
	dec_reg8 sc0,E_reg
	get_op
	 
x1e: @LD E,d8
	get_1_arg
	ld_reg8_d8 E_reg
	get_op
	 
x1f: @RRA


x20: @JR NZ,s8 - jump to (PC + s8) if Zero flag is reset - s8 is SIGNED
	get_1_arg_signed
	tst cpuflags,zflag_set
	it eq
	addeq progc,progc,args
	get_op

x21: @LD HL,d16 - no flags
	get_2_arg
	ld_rr_nn HL_reg,args
	get_op

x22: @LD (HL+),A - Same as LD (HL),A - INC HL
	ldrh sc3,[cpuregs,HL_reg]
	strh sc3,[cpuregs,SC_reg] @use a different register for small optimization
	add sc3,1
	strh sc3,[cpuregs,HL_reg]
	ldrb sc0,[cpuregs,A_reg]
	ld_ra16_d8 SC_reg,sc0,sc1,sc2
	get_op
   
x23: @INC HL
	inc_reg16 sc0,HL_reg
	get_op
	 
x24: @INC H
	inc_reg8 sc0,H_reg
	get_op
	 
x25: @DEC H
	dec_reg8 sc0,H_reg
	get_op
	 
x26: @LD H,d8
	get_1_arg
	ld_reg8_d8 H_reg
	get_op
	 
x27: @DAA
	 
x28: @JR Z,r8

	 
x29: @ADD HL,HL


x2a: @LD A,(HL+)

	 
x2b: @DEC HL
	dec_reg16 r0,HL_reg
	get_op
	 
x2c: @INC L
	inc_reg8 sc0,L_reg
	get_op
	 
x2d: @DEC L
	dec_reg8 sc0,L_reg
	get_op
	 
x2e: @LD L,d8
	get_1_arg
	ld_reg8_d8 L_reg
	get_op
	 
x2f: @CPL
	 
x30: @JR NC,r8

	 
x31: @LD sp,d16 - load immediate into stack pointer
	@This needs a mem catch - I cant really assume the stack is going to be in WRAM0
	get_2_arg
	sub args,0xc000 @need to subtract c000 because GBC I need the offset into wram
	cmp args,0x1000
	it mi
	addmi stackptr,sc0,cartaddr
   	get_op	

x32: @LD (HL-),A
	ldrh sc3,[cpuregs,HL_reg]
	strh sc3,[cpuregs,SC_reg] @use a different register for small optimization
	sub sc3,1
	strh sc3,[cpuregs,HL_reg]
	ldrb sc0,[cpuregs,A_reg]
	ld_ra16_d8 SC_reg,sc0,sc1,sc2
	get_op
	 
x33: @INC SP

	 
x34: @INC (HL)

	 
x35: @DEC (HL)

	 
x36: @LD (HL),d8
	get_1_arg
	ld_ra16_d8 HL_reg,args,sc0,sc1
	get_op

x37: @SCF
	 
x38: @JR C,r8

	 
x39: @ADD HL,SP

	 
x3a: @LD A,(HL-)

.ltorg
	 
x3b: @DEC SP

	 
x3c: @INC A
	inc_reg8 sc0,A_reg
	get_op

x3d: @DEC A
	dec_reg8 sc0,A_reg
	get_op
	 
x3e: @LD A,d8 - No flags affected 
	get_1_arg
	ld_reg8_d8 A_reg
	get_op
	 
x3f: @CCF
	 
x40: @LD B,B
	get_op
	 
x41: @LD B,C
	ld_reg8_reg8 sc0,B_reg,C_reg
	get_op
	 
x42: @LD B,D
	ld_reg8_reg8 sc0,B_reg,D_reg
	get_op
	 
x43: @LD B,E
	ld_reg8_reg8 sc0,B_reg,E_reg
	get_op
	 
x44: @LD B,H
	ld_reg8_reg8 sc0,B_reg,H_reg
	get_op
	 
x45: @LD B,L
	ld_reg8_reg8 sc0,B_reg,L_reg
	get_op
	 
x46: @LD B,(HL)

	 
x47: @LD B,A
	ld_reg8_reg8 sc0,B_reg,A_reg
	get_op
	 
x48: @LD C,B
	ld_reg8_reg8 sc0,C_reg,B_reg
	get_op
	 
x49: @LD C,C
	get_op
	 
x4a: @LD C,D
	ld_reg8_reg8 sc0,C_reg,D_reg
	get_op
	 
x4b: @LD C,E
	ld_reg8_reg8 sc0,C_reg,E_reg
	get_op
	 
x4c: @LD C,H
	ld_reg8_reg8 sc0,C_reg,H_reg
	get_op
	 
x4d: @LD C,L
	ld_reg8_reg8 sc0,C_reg,L_reg
	get_op
	 
x4e: @LD C,(HL)

	 
x4f: @LD C,A
	ld_reg8_reg8 sc0,C_reg,A_reg
	get_op
	 
x50: @LD D,B
	ld_reg8_reg8 sc0,D_reg,B_reg
	get_op
	 
x51: @LD D,C
	ld_reg8_reg8 sc0,D_reg,C_reg
	get_op
	 
x52: @LD D,D
	get_op
	 
x53: @LD D,E
	ld_reg8_reg8 sc0,D_reg,E_reg
	get_op
	 
x54: @LD D,H
	ld_reg8_reg8 sc0,D_reg,H_reg
	get_op
	 
x55: @LD D,L
	ld_reg8_reg8 sc0,D_reg,L_reg
	get_op
	 
x56: @LD D,(HL)

	 
x57: @LD D,A
	ld_reg8_reg8 sc0,D_reg,A_reg
	get_op
	 
x58: @LD E,B
	ld_reg8_reg8 sc0,E_reg,B_reg
	get_op
	 
x59: @LD E,C
	ld_reg8_reg8 sc0,E_reg,C_reg
	get_op
	 
x5a: @LD E,D
	ld_reg8_reg8 sc0,E_reg,D_reg
	get_op
	 
x5b: @LD E,E
	get_op
	 
x5c: @LD E,H
	ld_reg8_reg8 sc0,E_reg,H_reg
	get_op
	 
x5d: @LD E,L
	ld_reg8_reg8 sc0,E_reg,L_reg
	get_op
	 
x5e: @LD E,(HL)

	 
x5f: @LD E,A
	ld_reg8_reg8 sc0,E_reg,A_reg
	get_op
	 
x60: @LD H,B
	ld_reg8_reg8 sc0,H_reg,B_reg
	get_op
	 
x61: @LD H,C
	ld_reg8_reg8 sc0,H_reg,C_reg
	get_op
	 
x62: @LD H,D
	ld_reg8_reg8 sc0,H_reg,D_reg
	get_op
	 
x63: @LD H,E
	ld_reg8_reg8 sc0,H_reg,E_reg
	get_op
	 
x64: @LD H,H
	get_op
	 
x65: @LD H,L
	ld_reg8_reg8 sc0,H_reg,L_reg
	get_op
	 
x66: @LD H,(HL)

	 
x67: @LD H,A
	ld_reg8_reg8 sc0,H_reg,A_reg
	get_op
	 
x68: @LD L,B
	ld_reg8_reg8 sc0,L_reg,B_reg
	get_op
	 
x69: @LD L,C
	ld_reg8_reg8 sc0,L_reg,C_reg
	get_op
	 
x6a: @LD L,D
	ld_reg8_reg8 sc0,L_reg,D_reg
	get_op
	 
x6b: @LD L,E
	ld_reg8_reg8 sc0,L_reg,E_reg
	get_op
	 
x6c: @LD L,H
	ld_reg8_reg8 sc0,L_reg,H_reg
	get_op
	 
x6d: @LD L,L
	get_op
	 
x6e: @LD L,(HL)


x6f: @LD L,A
	ld_reg8_reg8 sc0,L_reg,A_reg
	get_op
	 

x70: @LD (HL),B
	ldrb sc0,[cpuregs,B_reg]
	ld_ra16_d8 HL_reg,sc0,sc1,sc2
	get_op
	
.ltorg
	
x71: @LD (HL),C
	ldrb sc0,[cpuregs,C_reg]
	ld_ra16_d8 HL_reg,sc0,sc1,sc2
	get_op
	 
.ltorg

x72: @LD (HL),D
	ldrb sc0,[cpuregs,D_reg]
	ld_ra16_d8 HL_reg,sc0,sc1,sc2
	get_op
	 
.ltorg

x73: @LD (HL),E
	ldrb sc0,[cpuregs,E_reg]
	ld_ra16_d8 HL_reg,sc0,sc1,sc2
	get_op
	 
x74: @LD (HL),H
	ldrb sc0,[cpuregs,H_reg]
	ld_ra16_d8 HL_reg,sc0,sc1,sc2
	get_op
	 
x75: @LD (HL),L
	ldrb sc0,[cpuregs,L_reg]
	ld_ra16_d8 HL_reg,sc0,sc1,sc2
	get_op
	 
x76: @HALT - clock stopped, oscillator and lcd controller keep going. cancelled by interrupt or reset signal
	@wait for interrupts
	get_op
	 
x77: @LD (HL),A
	ldrb sc0,[cpuregs,A_reg]
	ld_ra16_d8 HL_reg,sc0,sc1,sc2
	get_op
	 
x78: @LD A,B
	ld_reg8_reg8 sc0,A_reg,B_reg
	get_op
	 
x79: @LD A,C - no flags
	ld_reg8_reg8 sc0,A_reg,C_reg
	get_op
	 
x7a: @LD A,D
	ld_reg8_reg8 sc0,A_reg,D_reg
	get_op
	 
x7b: @LD A,E
	ld_reg8_reg8 sc0,A_reg,E_reg
	get_op
	 
x7c: @LD A,H
	ld_reg8_reg8 sc0,A_reg,H_reg
	get_op
	 
x7d: @LD A,L
	ld_reg8_reg8 sc0,A_reg,L_reg
	get_op
	 
x7e: @LD A,(HL)

	 
x7f: @LD A,A
	get_op
	 
x80: @ADD A,B
	add_reg8_reg8 r0,r8,r9,A_reg,B_reg
	get_op
	 
x81: @ADD A,C
	add_reg8_reg8 r0,r8,r9,A_reg,C_reg
	get_op
	 
x82: @ADD A,D
	add_reg8_reg8 r0,r8,r9,A_reg,D_reg
	get_op
	 
x83: @ADD A,E
	add_reg8_reg8 r0,r8,r9,A_reg,E_reg
	get_op
	 
x84: @ADD A,H
	add_reg8_reg8 r0,r8,r9,A_reg,H_reg
	get_op
	 
x85: @ADD A,L
	add_reg8_reg8 r0,r8,r9,A_reg,L_reg
	get_op
	 
x86: @ADD A,(HL)

	 
x87: @ADD A,A
	add_regA_regA r0
	get_op
	 
x88: @ADC A,B
	adc_reg8_reg8 r0,r8,r9,A_reg,B_reg
	get_op
	 
x89: @ADC A,C
	adc_reg8_reg8 r0,r8,r9,A_reg,C_reg
	get_op
	 
x8a: @ADC A,D
	adc_reg8_reg8 r0,r8,r9,A_reg,D_reg
	get_op
	 
x8b: @ADC A,E
	adc_reg8_reg8 r0,r8,r9,A_reg,E_reg
	get_op
	 
x8c: @ADC A,H
	adc_reg8_reg8 r0,r8,r9,A_reg,H_reg
	get_op
	 
x8d: @ADC A,L
	adc_reg8_reg8 r0,r8,r9,A_reg,L_reg
	get_op
	 
x8e: @ADC A,(HL)

	 
x8f: @ADC A,A
	adc_regA_regA r0
	get_op
	 
x90: @SUB B
	sub_A_reg8 r0,r8,r9,B_reg
	get_op 

x91: @SUB C
	sub_A_reg8 r0,r8,r9,C_reg
	get_op 
	 
x92: @SUB D
	sub_A_reg8 r0,r8,r9,D_reg
	get_op 
	 
x93: @SUB E
	sub_A_reg8 r0,r8,r9,E_reg
	get_op 
	 
x94: @SUB H
	sub_A_reg8 r0,r8,r9,H_reg
	get_op 
	 
x95: @SUB L
	sub_A_reg8 r0,r8,r9,L_reg
	get_op 
	 
x96: @SUB (HL)

	 
x97: @SUB A
	mov sc0,0
	strb sc0,[cpuregs,A_reg]
	mov cpuregs,0xc0	@Z,N = 1; H,C = 0
	get_op
	 
x98: @SBC A,B
	sbc_A_reg8 r0,r8,r9,B_reg
	get_op 
	 
x99: @SBC A,C
	sbc_A_reg8 r0,r8,r9,C_reg
	get_op 
	 
x9a: @SBC A,D
	sbc_A_reg8 r0,r8,r9,D_reg
	get_op 
	 
x9b: @SBC A,E
	sbc_A_reg8 r0,r8,r9,E_reg
	get_op 
	 
x9c: @SBC A,H
	sbc_A_reg8 r0,r8,r9,H_reg
	get_op 
	 
x9d: @SBC A,L
	sbc_A_reg8 r0,r8,r9,L_reg
	get_op 
	 
x9e: @SBC A,(HL)
	get_op
	 
x9f: @SBC A,A
	tst cpuflags,cflag_set
	ittee eq
	moveq r0,0xff
	moveq cpuflags,0x70  @Z=0; H,C,N = 1
	movne r0,0
	movne cpuflags,0xc0	@Z,N = 1; H,C = 0
	strb r0,[cpuregs,A_reg]
	get_op
	 
xa0: @AND B
	and_A_reg8 sc0,sc1,B_reg
	get_op
	 
xa1: @AND C
	and_A_reg8 sc0,sc1,C_reg
	get_op
	 
xa2: @AND D
	and_A_reg8 sc0,sc1,D_reg
	get_op
	 
xa3: @AND E
	and_A_reg8 sc0,sc1,E_reg
	get_op
	 
xa4: @AND H
	and_A_reg8 sc0,sc1,H_reg
	get_op
	 
xa5: @AND L
	and_A_reg8 sc0,sc1,L_reg
	get_op
	 
xa6: @AND (HL)

	 
xa7: @AND A
	ldrb sc0,[cpuregs,A_reg]
	tst sc0,sc0
	ite eq
	moveq cpuflags,0xa0    @Z,H = 1; N,C = 0
	movne cpuflags,0x20	  @H = 1; Z,N,C = 0
	get_op
	 
xa8: @XOR B

	 
xa9: @XOR C

	 
xaa: @XOR D

	 
xab: @XOR E

	 
xac: @XOR H

	 
xad: @XOR L

	 
xae: @XOR (HL)

	 
xaf: @XOR A - A^A, Z is set if 0, NHC cleared

	 
xb0: @OR B - Logical OR with A, store result in A - z if result is 0, nhc are reset
 
	 
xb1: @OR C

	 
xb2: @OR D

	 
xb3: @OR E

	 
xb4: @OR H

	 
xb5: @OR L

	 
xb6: @OR (HL)

	 
xb7: @OR A

	 
xb8: @CP B
	cp_A_reg8 sc0,sc1,B_reg
	get_op
	 
xb9: @CP C
	cp_A_reg8 sc0,sc1,C_reg
	get_op
	 
xba: @CP D
	cp_A_reg8 sc0,sc1,D_reg
	get_op
	 
xbb: @CP E
	cp_A_reg8 sc0,sc1,E_reg
	get_op
	 
xbc: @CP H
	cp_A_reg8 sc0,sc1,H_reg
	get_op
	 
xbd: @CP L
	cp_A_reg8 sc0,sc1,L_reg
	get_op
	 
xbe: @CP (HL)

	 
xbf: @CP A - I feel like this is too easy, CP A is always going to be 0
	mov cpuflags,0xc0
	get_op
	 
xc0: @RET NZ

	 
xc1: @POP BC

	 
xc2: @JP NZ,a16
	get_2_arg
	tst cpuflags,zflag_set
	it eq			@zflag is not set if result of tst is 0
	addeq progc,args,cartaddr
	get_op

xc3: @JP a16
	get_2_arg
	add progc,args,cartaddr
	get_op

xc4: @CALL NZ,a16

	 
xc5: @PUSH BC

	 
xc6: @ADD A,d8

	 
xc7: @RST 00H

	 
xc8: @RET Z

	 
xc9: @RET

	 
xca: @JP Z,a16
	get_2_arg
	tst cpuflags,zflag_set
	it ne
	addne progc,args,cartaddr
	get_op

	 
xcb: @PREFIX CB
	get_1_arg	@args holds the CB opcode
	ldr sc0,=cb_lbl
	ldr pc,[sc0,args,lsl 2]
	 
xcc: @CALL Z,a16

	 
xcd: @CALL a16 - push addr of next instruction to stack and jump to a16

	 
xce: @ADC A,d8

	 
xcf: @RST 08H

	 
xd0: @RET NC

	 
xd1: @POP DE

	 
xd2: @JP NC,a16

	 
xd3: @unused

	 
xd4: @CALL NC,a16

	 
xd5: @PUSH DE

	 
xd6: @SUB d8

	 
xd7: @RST 10H

	 
xd8: @RET C

	 
xd9: @RETI

	 
xda: @JP C,a16

	 
xdb: @unused
	 
xdc: @CALL C,a16

	 
xdd:@unused
	 
xde: @SBC A,d8

	 
xdf: @RST 18H

	 
xe0: @LDH (a8),A

	 
xe1: @POP HL

	 
xe2: @LD (C),A - write to IO port at address (0xFF00 + (C)) the contents of A

	 
xe3:@unused
	 
xe4:@unused
	 
xe5: @PUSH HL

	 
xe6: @AND d8 - Z is set if AND is 0, N is reset, H is set, C is reset

	 
xe7: @RST 20H

	 
xe8: @ADD SP,r8

	 
xe9: @JP (HL)

	 
xea: @LD (a16),A - put A into address (a16) addr fix
	get_2_arg
	strh args,[cpuregs,SC_reg]
	ldrb sc0,[cpuregs,A_reg]
	ld_ra16_d8 SC_reg,sc0,sc1,sc2
	get_op
	 
xeb:@unused
	 
xec:@unused
	 
xed:@unused
	 
xee: @XOR d8

	 
xef: @RST 28H

	 
xf0: @LDH A,(a8) - store the address (0xFF00 + a8) into A - I/O DATA

xf1: @POP AF

	 
xf2: @LD A,(C) - Load (0xFF00 + (C)) into reg A (read i/o into A)
	

xf3: @Disable interrupts
	@do something
	get_op

xf4:@unused
	 
xf5: @PUSH AF

	 
xf6: @OR d8

	 
xf7: @RST 30H

	 
xf8: @LD HL,SP+r8

	 
xf9: @LD SP,HL

	 
xfa: @LD A,(a16)

	 
xfb: @EI
	 
xfc:@unused
	 
xfd:@unused


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

xff: @RST 38H



cb00: @RLC B - Rotate B. old bit 7 goes to carry and to bit 0. Z is conditionally set, N,H cleared
	cb_rlc_r8 sc0,B_reg
	get_op

cb01: @RLC C
	cb_rlc_r8 sc0,C_reg
	get_op

cb02: @RLC D
	cb_rlc_r8 sc0,D_reg
	get_op

cb03: @RLC E 
	cb_rlc_r8 sc0,E_reg
	get_op

cb04: @RLC H
	cb_rlc_r8 sc0,H_reg
	get_op

cb05: @RLC L
	cb_rlc_r8 sc0,L_reg
	get_op

cb06: @RLC (HL)


cb07: @RLC A
	cb_rlc_r8 sc0,A_reg
	get_op

cb08:

cb09:

cb0a:

cb0b:

cb0c:

cb0d:

cb0e:

cb0f:

cb10:

cb11:

cb12:

cb13:

cb14:

cb15:

cb16:

cb17:

cb18:

cb19:

cb1a:

cb1b:

cb1c:

cb1d:

cb1e:

cb1f:

cb20:

cb21:

cb22:

cb23:

cb24:

cb25:

cb26:

cb27:

cb28:

cb29:

cb2a:

cb2b:

cb2c:

cb2d:

cb2e:

cb2f:

cb30: @SWAP B - set z conditionally, N,H,C cleared
	cb_swap_r8 sc0,B_reg
	get_op

cb31: @SWAP C
	cb_swap_r8 sc0,C_reg
	get_op

cb32: @SWAP D
	cb_swap_r8 sc0,D_reg
	get_op

cb33: @SWAP E
	cb_swap_r8 sc0,E_reg
	get_op

cb34: @SWAP H
	cb_swap_r8 sc0,H_reg
	get_op

cb35: @SWAP L
	cb_swap_r8 sc0,L_reg
	get_op

cb36: @SWAP (HL)
	get_op

cb37: @SWAP A
	cb_swap_r8 sc0,A_reg
	get_op

cb38:

cb39:

cb3a:

cb3b:

cb3c:

cb3d:

cb3e:

cb3f:

cb40: @BIT 0,B
	cb_bit sc0,0,B_reg
	get_op

cb41:

cb42:

cb43:

cb44:

cb45:

cb46:

cb47:

cb48:

cb49:

cb4a:

cb4b:

cb4c:

cb4d:

cb4e:

cb4f:

cb50:

cb51:

cb52:

cb53:

cb54:

cb55:

cb56:

cb57:

cb58:

cb59:

cb5a:

cb5b:

cb5c:

cb5d:

cb5e:

cb5f:

cb60:

cb61:

cb62:

cb63:

cb64:

cb65:

cb66:

cb67:

cb68:

cb69:

cb6a:

cb6b:

cb6c:

cb6d:

cb6e:

cb6f:

cb70:

cb71:

cb72:

cb73:

cb74:

cb75:

cb76:

cb77:

cb78:

cb79:

cb7a:

cb7b:

cb7c:

cb7d:

cb7e:

cb7f:

cb80: @RES 0,B
	cb_reset_bit sc0,0,B_reg
	get_op


cb81:

cb82:

cb83:

cb84:

cb85:

cb86:

cb87:

cb88:

cb89:

cb8a:

cb8b:

cb8c:

cb8d:

cb8e:

cb8f:

cb90:

cb91:

cb92:

cb93:

cb94:

cb95:

cb96:

cb97:

cb98:

cb99:

cb9a:

cb9b:

cb9c:

cb9d:

cb9e:

cb9f:

cba0:

cba1:

cba2:

cba3:

cba4:

cba5:

cba6:

cba7:

cba8:

cba9:

cbaa:

cbab:

cbac:

cbad:

cbae:

cbaf:

cbb0:

cbb1:

cbb2:

cbb3:

cbb4:

cbb5:

cbb6:

cbb7:

cbb8:

cbb9:

cbba:

cbbb:

cbbc:

cbbd:

cbbe:

cbbf:

cbc0:

cbc1:

cbc2:

cbc3:

cbc4:

cbc5:

cbc6:

cbc7:

cbc8:

cbc9:

cbca:

cbcb:

cbcc:

cbcd:

cbce:

cbcf:

cbd0:

cbd1:

cbd2:

cbd3:

cbd4:

cbd5:

cbd6:

cbd7:

cbd8:

cbd9:

cbda:

cbdb:

cbdc:

cbdd:

cbde:

cbdf:

cbe0:

cbe1:

cbe2:

cbe3:

cbe4:

cbe5:

cbe6:

cbe7:

cbe8:

cbe9:

cbea:

cbeb:

cbec:

cbed:

cbee:

cbef:

cbf0:

cbf1:

cbf2:

cbf3:

cbf4:

cbf5:

cbf6:

cbf7:

cbf8:

cbf9:

cbfa:

cbfb:

cbfc:

cbfd:

cbfe:

cbff:




