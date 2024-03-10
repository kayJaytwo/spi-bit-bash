

		  .global ASM_spi_write_var

//------------------------------------------------------------------------------------------------
/*
	Write variable data size packet
	data is passed in arg[1] and is in R0
	size is passed as arg[2] and is in R1 register
*/
ASM_spi_write_var:

	  PUSH  {R5, R6 }
	  MOV R2,#32
	  SUB R2,R1
	  LSL R0, R2     // align the data word size to the left msb bit

	  LDR R2,   =GPIO_BASE   // address of the GPIO port
      LDR R4,	=#(CLK_LOW | SDA_HIGH | SCS_LOW)			// preload clock low
      LDR R5,	=#(CLK_HIGH)
      LDR R6,	=#(CLK_LOW | SDA_LOW | SCS_LOW)

do_1_bit2:
	  // Get msb bit into carry
	  LSLS R0, R0, #1
	  BCC  bit_zero2			    // branch no carry set
      STR R4, [R2, #o_GPIO_BSRR]	// clk low Tx bit = 1
      B    delay_low1

bit_zero2:   						   //Tx bit = 0

	  STR R6, [R2, #o_GPIO_BSRR]    // Clk low Tx = 0
	  NOP
	  NOP


delay_low1:
#ifdef USE_DELAY
	  LDR R3, =CLK_LOW_TIME				// half of the spi clk period

bit_delay12:
	  SUBS R3, R3, #1                  	// R3 -1
	  BNE bit_delay12                	// stay in loop delay1 if not equal to zero
#endif


	  SUBS R1, R1, #1					// decrement bit count branch if not zero
	  STR R5, [R2, #o_GPIO_BSRR]       // Set clock high

#ifdef USE_DELAY

	  LDR R3, =CLK_HIGH_TIME			//
bit_delay22:
	  SUBS R3, R3, #1                  // R3 -1
	  BNE bit_delay22
#endif

	  BNE do_1_bit2

	  LDR R3, =#(SCS_HIGH | CLK_LOW )
	  STR R3, [R2, #o_GPIO_BSRR]		// write SCK low and data on SDA
      POP  {R5, R6 }
	//  BX LR                            // Return from function

