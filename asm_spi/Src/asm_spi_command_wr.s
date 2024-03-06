
	  .syntax unified

	  .text
	  .global ASM_spi_command_write


	//------------------------------------------------------------------------------------------------
	/*
		Write fixed 8bit byte data size packet
		data is passed in arg[1] and is in the R0  reg
	   Use only registers R0-4 as these are preserved by the caller

	*/
 ASM_spi_command_wr:

	  LDR R1, =GPIO_BSRR
	  LDR R2, =#DATA_SIZE

	  cmw_do_1_bit:
	  // Get msb bit into carry

	  LSLS R0, R0, #1
	  BCC  cmw_bit_zero			// branch no carry set

#ifdef USE_CS
	  LDR R3,  =#(CLK_LOW | SDA_HIGH | SCS_LOW)		//Tx bit is 1
	  B cmw_write_bit

 cmw_bit_zero:   						//Tx bit is 0
	   LDR R3,	=#(CLK_LOW | SDA_LOW | SCS_LOW)
#else
	  LDR R3,  =#(CLK_LOW | SDA_HIGH )		//Tx bit is 1
	  B cmw_write_bit

  cmw_bit_zero:   						//Tx bit is 0
	   LDR R3,	=#(CLK_LOW | SDA_LOW )
#endif

  cmw_write_bit:
	    STR R3, [R1]					// write SCK high and data on SDA

	  LDR R3, =CLK_LOW_TIME			   // half the o time compared to offtime
  cmw_bit_delay1:
	  SUBS R3, R3, #1                  	// R3 -1
	  BNE cmw_bit_delay1                	// stay in loop delay1 if not equal to zero

	  LDR R3, =#(CLK_HIGH)				// set SCK low and keep data on SDA
	  STR R3, [R1]

	  LDR R3, =CLK_HIGH_TIME			//
  cmw_bit_delay2:
	  SUBS R3, R3, #1                  // R3 -1
	  BNE cmw_bit_delay2

	  SUBS R2, R2, #1
	  BNE cmw_do_1_bit

#ifdef USE_CS
	  LDR R3,	=#(SCS_HIGH)			// Set CS high
	  STR R3, [R1]
#endif

	  BX LR                            // Return from function
