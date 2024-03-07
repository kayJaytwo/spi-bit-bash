	/*
	 * assembler.s
	 *
	 *  Created on: Mar 2, 2024
	 *      Author: Ken
	 */

	  .syntax unified

	  .text
	  .global ASM_spi_read
	  .thumb_func


	//------------------------------------------------------------------------------------------------

	/*
	    Read data from slave

		data is return in the R0  reg
		read command is passed as arg[1] and is in R0 reg
		read size is passed as arg[2] and is in R1 reg

		extended to add in a write command followed by read back of data size

	   Use only registers R0-4 as these are preserved by the caller

	*/
	  ASM_spi_read:


	  MOV   R4,R1					 	// save data field size
	  LDR R2, =GPIO_BASE		 			// load mode register address

	  LDR R3, =#(CLK_LOW | SCS_LOW)			// Chip Select active
	  STR R3, [R2, #o_GPIO_BSRR]

 #include "asm_spi_command_wr.s" 			// write the command

	 // set port mode to input


	  // get the current gpio mode and set SDA pin to input
	  LDR R3, [R2, #o_GPIO_MODER]			// read mode reg
	  AND R3, #(SDA_MODE_mask_pos)			// modify no need to OR in the pin bits as they are 0x00
	  STR R3, [R2, #o_GPIO_MODER]			// write


	  // temp use pull up
#ifdef PULLUP_ON
	   LDR R3, [R2, #o_GPIO_PUPDR]
 	   ORR R3, =#(0x08000000)
 	   STR R3, [R2, #o_GPIO_PUPDR]
#endif

	LDR R0,=#0							// Clear,  rx data register

 loopA:

	  LDR R3,  =#(CLK_LOW)				//Start low clock cycle
	  STR R3, [R2, #o_GPIO_BSRR]		// write SCK low

	  LDR R3, =CLK_LOW_TIME				// the low clock  time delay loop
 bit_delay14:
	  SUBS R3, R3, #1                  	// R3 -1
	  BNE bit_delay14                	// stay in loop delay1 if not equal to zero

	  LDR R3, =#(CLK_HIGH)				// set SCK high
	  STR R3, [R2, #o_GPIO_BSRR]


	  LDR  R3, [R2, #o_GPIO_IDR]	 	// read input on gpio port
	  ASR  R3, #(SDA_pos+1)				// shift  data bit right into carry bit
	  ADC  R0, #0						// add carry into rx data word

	  LDR R3, =CLK_HIGH_TIME			//
 bit_delay24:
	  SUBS R3, R3, #1                   // R3 -1
	  BNE bit_delay24

	  SUBS R4, R4, #1					// dec bit count
	  BEQ  exit							// exit loop on zero bit count
	  LSL  R0, #1
	  B  loopA

 exit:

	  LDR R3, [R2, #o_GPIO_MODER]
	  ORR R3, #(SDA_OUT)			// Set SDA mode to output
	  STR R3, [R2, #o_GPIO_MODER]

	  LDR R3, =#(CLK_LOW | SCS_HIGH)			// Chip Select active
	  STR R3, [R2, #o_GPIO_BSRR]

	  BX LR                            // Return from function

	//------------------------------------------------------------------------------------------------
