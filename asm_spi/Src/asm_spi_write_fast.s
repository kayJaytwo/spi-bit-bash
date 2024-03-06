
	//------------------------------------------------------------------------------------------------
	/*
		Write variable data size packet
		size is passed as arg[2] and is in R1 register on entry
		This is a no delay routine, therefore represents the fastest
		clock & data rate possible at the given master clock frequency.

	*/


	  	  .text
	  .global ASM_spi_write_fast
	  .thumb_func


	  ASM_spi_write_fast:

	// Use registers R0-4 as these are preserved by the caller
	// data byte for tx is passed in R0
	  LDR R2, =GPIO_BSRR

	  do_1_bit3:
	  // Get msb bit into carry

	  LSLS R0, R0, #1
	  BCC  bit_zero3			// branch no carry set


	  LDR R3,	=#(CLK_LOW | SDA_HIGH)		//Tx bit is 1
	  B write_bit3

	  bit_zero3:   						//Tx bit is 0
	   LDR R3,	=#(CLK_LOW | SDA_LOW)

	  write_bit3:
	    STR R3, [R2]					// write SCK low and data on SDA
		NOP
		NOP
		NOP
	/*
	  LDR R3, =CLK_HIGH_TIME			// half the o time compared to offtime

	  bit_delay12:
	  SUBS R3, R3, #1                  	// R3 -1
	  BNE bit_delay12                	// stay in loop delay1 if not equal to zero
	*/


	  LDR R3, =#(CLK_HIGH)	  		// set SCK high and keep data on SDA
	  STR R3, [R2]
	/*
	  LDR R3, =CLK_LOW_TIME				//
	  bit_delay22:
	  SUBS R3, R3, #1                  // R3 -1
	  BNE bit_delay22
	*/
	  SUBS R1, R1, #1					// decrement bit count branch if not zero
	  BNE do_1_bit3

	  BX LR                            // Return from function


