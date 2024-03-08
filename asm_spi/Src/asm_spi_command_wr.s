
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

	  LDR R1, =#DATA_SIZE
      LSL R0, #PRE_SHIFT

 cmw_do_1_bit:

	  LSLS R0, R0, #1						// Get msb bit into carry
	  BCC  cmw_bit_zero						// branch no carry set

	  LDR R3,  =#(CLK_LOW | SDA_HIGH )		//Tx bit is 1
	  B cmw_write_bit

  cmw_bit_zero:   							//Tx bit is 0
	   LDR R3,	=#(CLK_LOW | SDA_LOW )

  cmw_write_bit:
	    STR R3,  [R2, #o_GPIO_BSRR]			// write SCK high and data on SDA

#ifdef USE_DELAY
	  LDR R3, =CLK_LOW_TIME			     // half the o time compared to offtime
  cmw_bit_delay1:
	  SUBS R3, R3, #1                  	// R3 -1
	  BNE cmw_bit_delay1                	// stay in loop delay1 if not equal to zero
#else
	  NOP								// supply some minimum low phase clock cycle
	  NOP
	  Nop
	  NOP
	  SUBS R1, R1, #1					// decrement the bit counter
#endif
	  LDR R3, =#(CLK_HIGH)				// set SCK low and keep data on SDA
	  STR R3,  [R2, #o_GPIO_BSRR]

#ifdef USE_DELAY
	  LDR R3, =CLK_HIGH_TIME			//
  cmw_bit_delay2:
	  SUBS R3, R3, #1                  // R3 -1
	  BNE cmw_bit_delay2
#endif


	  BNE cmw_do_1_bit


