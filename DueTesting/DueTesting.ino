#include "SAM3XDUE.h"

extern "C" void gbc(void);
void start_peripherals();


void setup() {
	NVIC_DisableIRQ(SysTick_IRQn);
	//delayMicros(1500000);
	start_peripherals();
	volatile int test = 0;
	++test;
	//delayMicros(1000);
	gbc();
}


void loop() {

}


void start_peripherals() {
	pmc_enable_periph_clk(ID_SMC);
	pmc_enable_periph_clk(ID_SPI0);
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
	REG_SMC_MODE0 = 1 | (1 << 1); //Read/ write is controlled by NRD/NWE
	REG_SMC_MODE1 = 1 | (1 << 1); //Read/ write is controlled by NRD/NWE
	REG_SMC_SETUP0 = 10 | (10 << 8) | (10 << 16) | (10 << 24);
	REG_SMC_PULSE0 = 10 | (10 << 8) | (10 << 16) | (10 << 24);
	REG_SMC_CYCLE0 = 25 | (25 << 16);
	REG_SMC_SETUP1 = 10 | (10 << 8) | (10 << 16) | (10 << 24);
	REG_SMC_PULSE1 = 10 | (10 << 8) | (10 << 16) | (10 << 24);
	REG_SMC_CYCLE1 = 25 | (25 << 16);

	//SPI setup
}