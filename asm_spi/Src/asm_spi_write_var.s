

		  .global ASM_spi_write_var

	//------------------------------------------------------------------------------------------------
	/*
		Write variable data size packet
		data is passed in arg[1] and is in R0
		size is passed as arg[2] and is in R1 register
	*/
ASM_spi_write_var:

	  LDR R2, =GPIO_BASE   // address of the GPIO port

do_1_bit2:
	  // Get msb bit into carry

	  LSLS R0, R0, #1
	  BCC  bit_zero2			// branch no carry set


	   LDR R3,	=#(CLK_LOW | SDA_HIGH | SCS_LOW)
	  B write_bit2

bit_zero2:   						//Tx bit is 0
	   LDR R3,	=#(CLK_LOW | SDA_LOW | SCS_LOW)

write_bit2:
	    STR R3, [R2, #o_GPIO_BSRR]					// write SCK low and data on SDA

	  LDR R3, =CLK_LOW_TIME			// half the o time compared to offtime

bit_delay12:
	  SUBS R3, R3, #1                  	// R3 -1
	  BNE bit_delay12                	// stay in loop delay1 if not equal to zero

	  LDR R3, =#(CLK_HIGH )				// set SCK high and keep data on SDA
	  STR R3, [R2, #o_GPIO_BSRR]

	  LDR R3, =CLK_HIGH_TIME			//

bit_delay22:
	  SUBS R3, R3, #1                  // R3 -1
	  BNE bit_delay22

	  SUBS R1, R1, #1					// decrement bit count branch if not zero
	  BNE do_1_bit2

	  LDR R3,	=#(SCS_HIGH)
	  STR R3, [R2, #o_GPIO_BSRR]				// write SCK low and data on SDA

	  BX LR                            // Return from function

