#include "SAM3XDUE.h"

extern "C" void gbc(void);
void start_peripherals();

extern "C" {
	int main(void) {
		SystemInit();
		NVIC_DisableIRQ(SysTick_IRQn);
		//delayMicros(1000000);
		start_peripherals();
		delayMicros(1000);
		gbc();

		while (1) {

		}
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