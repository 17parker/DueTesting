#include "SAM3XDUE.h"

extern "C" void gbc(void);

/*
	The space reserved for the entire memory map and the color data leaves about 3,072 bytes free
	That's before the rest of the program is taken into account

	I'm not using the NAND Flash Controller, so I get another 4,224 bytes of SRAM
	That starts at address 0x2010 0000
	Loading/storing addresses is relatively expensive, so that might be good for DMA stuff


	I'm not sure where to put this, but here's the timing requirements for the CPU to hit full speed:
		GB CPU freq: 4.194304 MHz
		Due CPU freq: 84,000,000 MHz
		20.027 (rounded down to 20) Due CPU cycles per GB CPU cycle

		4 cycle instructions must be completed within 80 cycles
		
		This is just for the CPU and doesn't take audio/ppu into consideration
		IDK if full speed is possible
*/

extern "C" {
	void start_peripherals();
	void start_lcd();	
	
	int main(void) {
		SystemInit();
		NVIC_DisableIRQ(SysTick_IRQn);
		//delayMicros(1000000);
		//start_lcd();
		start_peripherals();
		delayMicros(1000);
		gbc();

		while (1) {

		}
	}
}


//Thanks to the adafruit github, even they don't know what most of this does
//16 bits/px
const uint8_t lcd_init_data[] = {
  0xEF, 0,
  0xEB, 1, 0x14, // ?
  0xFE, 0,
  0xEF, 0,
  0xEB, 1, 0x14, // ?
  0x84, 1, 0x40, // ?
  0x85, 1, 0xFF, // ?
  0x86, 1, 0xFF, // ?
  0x87, 1, 0xFF, // ?
  0x88, 1, 0x0A, // ?
  0x89, 1, 0x21, // ?
  0x8A, 1, 0x00, // ?
  0x8B, 1, 0x80, // ?
  0x8C, 1, 0x01, // ?
  0x8D, 1, 0x01, // ?
  0x8E, 1, 0xFF, // ?
  0x8F, 1, 0xFF, // ?
  0xB6, 2, 0x00, 0x00, // ?
  0xEF, 1, 0x40 | 0x08,
  0x3A, 1, 0x05,
  0x90, 4, 0x08, 0x08, 0x08, 0x08, // ?
  0xBD, 1, 0x06, // ?
  0xBC, 1, 0x00, // ?
  0xFF, 3, 0x60, 0x01, 0x04, // ?
  0xC3, 1, 0x13,
  0xC4, 1, 0x13,
  0xC9, 1, 0x22,
  0xBE, 1, 0x11, // ?
  0xE1, 2, 0x10, 0x0E, // ?
  0xDF, 3, 0x21, 0x0c, 0x02, // ?
  0xF0, 6, 0x45, 0x09, 0x08, 0x08, 0x26, 0x2A,
  0xF1, 6, 0x43, 0x70, 0x72, 0x36, 0x37, 0x6F,
  0xF2, 6, 0x45, 0x09, 0x08, 0x08, 0x26, 0x2A,
  0xF3, 6, 0x43, 0x70, 0x72, 0x36, 0x37, 0x6F,
  0xED, 2, 0x1B, 0x0B, // ?
  0xAE, 1, 0x77, // ?
  0xCD, 1, 0x63, // ?
  0xE8, 1, 0x34,
  0x62, 12, 0x18, 0x0D, 0x71, 0xED, 0x70, 0x70, // ?
			0x18, 0x0F, 0x71, 0xEF, 0x70, 0x70,
  0x63, 12, 0x18, 0x11, 0x71, 0xF1, 0x70, 0x70, // ?
			0x18, 0x13, 0x71, 0xF3, 0x70, 0x70,
  0x64, 7, 0x28, 0x29, 0xF1, 0x01, 0xF1, 0x00, 0x07, // ?
  0x66, 10, 0x3C, 0x00, 0xCD, 0x67, 0x45, 0x45, 0x10, 0x00, 0x00, 0x00, // ?
  0x67, 10, 0x00, 0x3C, 0x00, 0x00, 0x00, 0x01, 0x54, 0x10, 0x32, 0x98, // ?
  0x74, 7, 0x10, 0x85, 0x80, 0x00, 0x00, 0x4E, 0x00, // ?
  0x98, 2, 0x3e, 0x07, // ?
  0x35, 0,
  0x21, 0,
  0x11, 0x80, // Exit sleep
  0x29, 0x80, // Display on
  0x00
};


//send low for command (NCS0), high for data (NCS1)
//data uses the NPCS1 "channel"
#define LCD_SEND_DATA(data)\
do{\
REG_SPI0_TDR = (data | (0b1101 << 16));\ 
delayMicros(15);\
} while (0)

#define LCD_SEND_CMD(cmd)\
do{\
REG_SPI0_TDR = (cmd);\
delayMicros(15);\
} while (0)

void start_lcd() {
	pmc_enable_periph_clk(ID_SPI0);

	const uint8_t baud_div = 84;
	delayMicros(1000);
	pio_enable_output(PIOA, SPI0_MOSI | SPI0_SCK | SPI0_NPCS0 | SPI0_NPCS1);
	pio_disable_output(PIOA, SPI0_MISO);
	pio_disable_pullup(PIOA, SPI0_MOSI | SPI0_MISO | SPI0_SCK | SPI0_NPCS0 | SPI0_NPCS1);
	pio_disable_pio(PIOA, SPI0_MOSI | SPI0_MISO | SPI0_SCK | SPI0_NPCS0 | SPI0_NPCS1);
	pio_set_periph_mode_A(PIOA, SPI0_MOSI | SPI0_MISO | SPI0_SCK | SPI0_NPCS0 | SPI0_NPCS1);
	REG_SPI0_CSR = (1 << 1) | (1 << 2) | (baud_div << 8); //CPOL = 0, NCPHA = 1, CSNAAT = 1, CSAAT = 0, 8 bits/xfer
	*((volatile uint32_t*)0x40008034U) = (1 << 1) | (1 << 2) | (baud_div << 8); //REG_SPI0_CSR1
	REG_SPI0_MR = 1 | (1 << 1) | (1 << 4); //master mode, variable peripheral select, no decode/fault/delay
	REG_SPI0_CR = 1; //enable spi
	delayMicros(1000);

	uint8_t cmd, x, numArgs;
	const uint8_t* addr = lcd_init_data;
	while ((cmd = *addr++) > 0) {
		x = *addr++;
		numArgs = x & 0x7F;
		LCD_SEND_CMD(cmd);
		for (uint8_t i = 0; i < numArgs; ++i)
			LCD_SEND_DATA((*addr++));
		if (x & 0x80)
			delayMicros(150000);
	}

	LCD_SEND_CMD(0x2A); //column address set
	LCD_SEND_DATA(0);
	LCD_SEND_DATA(48);
	LCD_SEND_DATA(0);
	LCD_SEND_DATA(191);

	LCD_SEND_CMD(0x2B); //page address set
	LCD_SEND_DATA(0);
	LCD_SEND_DATA(40);
	LCD_SEND_DATA(0);
	LCD_SEND_DATA(199);

	LCD_SEND_CMD(0x2C);
	uint8_t dat = 0;
	while (true) {
		LCD_SEND_DATA(0xaa);
	}
}

void start_peripherals() {
	pmc_enable_periph_clk(ID_SMC);
	//pmc_enable_periph_clk(ID_SPI0);
	pio_enable_output(PIOA, (1 << 6) | (1 << 7) | (1 << 25) | (1 << 26) | (1 << 27) | (1 << 28) | (1 << 29));
	pio_disable_pullup(PIOA, (1 << 6) | (1 << 7) | (1 << 25) | (1 << 26) | (1 << 27) | (1 << 28) | (1 << 29));
	pio_disable_pio(PIOA, (1 << 6) | (1 << 7) | (1 << 25) | (1 << 26) | (1 << 27) | (1 << 28) | (1 << 29));
	pio_set_periph_mode_B(PIOA, (1 << 6) | (1 << 7) | (1 << 29));
	pio_set_periph_mode_A(PIOA, (1 << 25) | (1 << 26) | (1 << 27) | (1 << 28));

	pio_enable_output(PIOC, (1 << 2) | (1 << 3) | (1 << 4) | (1 << 5) | (1 << 6) | (1 << 7)
		| (1 << 8) | (1 << 9) | (1 << 18) | (1 << 21) | (1 << 22) | (1 << 23) | (1 << 24) | (1 << 25) | (1 << 26) |
		(1 << 27) | (1 << 28) | (1 << 29) | (1 << 30));
	pio_disable_pullup(PIOC, (1 << 2) | (1 << 3) | (1 << 4) | (1 << 5) | (1 << 6) | (1 << 7)
		| (1 << 8) | (1 << 9) | (1 << 18) | (1 << 21) | (1 << 22) | (1 << 23) | (1 << 24) | (1 << 25) | (1 << 26) |
		(1 << 27) | (1 << 28) | (1 << 29) | (1 << 30));
	pio_disable_pio(PIOC, (1 << 2) | (1 << 3) | (1 << 4) | (1 << 5) | (1 << 6) | (1 << 7)
		| (1 << 8) | (1 << 9) | (1 << 18) | (1 << 21) | (1 << 22) | (1 << 23) | (1 << 24) | (1 << 25) | (1 << 26) |
		(1 << 27) | (1 << 28) | (1 << 29) | (1 << 30));
	pio_set_periph_mode_A(PIOC, (1 << 2) | (1 << 3) | (1 << 4) | (1 << 5) | (1 << 6) | (1 << 7)
		| (1 << 8) | (1 << 9) | (1 << 18) | (1 << 21) | (1 << 22) | (1 << 23) | (1 << 24) | (1 << 25) | (1 << 26) |
		(1 << 27) | (1 << 28) | (1 << 29) | (1 << 30));

	pio_enable_output(PIOD, 1 | (1 << 1) | (1 << 2) | (1 << 3) | (1 << 4) | (1 << 5));
	pio_disable_pullup(PIOD, 1 | (1 << 1) | (1 << 2) | (1 << 3) | (1 << 4) | (1 << 5));
	pio_disable_pio(PIOD, 1 | (1 << 1) | (1 << 2) | (1 << 3) | (1 << 4) | (1 << 5));
	pio_set_periph_mode_A(PIOD, 1 | (1 << 1) | (1 << 2) | (1 << 3) | (1 << 4) | (1 << 5));

	//SMC setup
	REG_SMC_MODE0 = 0; //Read controlled by NCS, write is controlled by NWE
	REG_SMC_MODE1 = 0; //Read controlled by NCS, write is controlled by NWE
	REG_SMC_SETUP0 = 23 | (0 << 8) | (0 << 16) | (5 << 24);
	REG_SMC_PULSE0 = 28 | (62 << 8) | (62 << 16) | (56 << 24);
	REG_SMC_CYCLE0 = 75 | (75 << 16);
	REG_SMC_SETUP1 = 23 | (0 << 8) | (0 << 16) | (5 << 24);
	REG_SMC_PULSE1 = 28 | (62 << 8) | (62 << 16) | (56 << 24);
	REG_SMC_CYCLE1 = 75 | (75 << 16);

	//SPI setup
}