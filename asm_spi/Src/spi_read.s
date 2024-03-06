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

//#include "asm_defines"

	//------------------------------------------------------------------------------------------------

	/*
	    Read 8 data bit from slave
	    bit count is entered in R0
		data is return in the R0  reg
		size is passed as arg[1] and is in R0 reg

		extended to add in a write command followed by read back of data size

	   Use only registers R0-4 as these are preserved by the caller

	*/
	  ASM_spi_read:
	  PUSH {R0}			// save data field size
	  MOV  R0,R1		// move command into R0
	  //
	  BL    ASM_spi_command_wr
	  POP {R0}
	 // set port mode to input
	  LDR R1, =GPIO_BASE		  // load mode register address
	  // get the current gpio mode and set SDA pin to input
	  LDR R2, [R1, #o_GPIO_MODER]
	  LDR R3, =#(SDA_MODE_mask_pos)			//
	  AND R2, R3
	  STR R2, [R1, #o_GPIO_MODER]


	  // temp use pull up
#ifdef PULLUP_ON
	   LDR R2, [R1, #o_GPIO_PUPDR]
 	   LDR R3, =#(0x08000000)
 	   STR R3, [R1, #o_GPIO_PUPDR]
#endif

	   MOV R2,R0						// set bit transfer count
	   LDR R0, =#(0x0000)				// Clear RO return result reg

 loopA:

	  LDR R3,  =#(CLK_LOW)				//Start low clock cycle
	  STR R3, [R1, #o_GPIO_BSRR]		// write SCK low

	  LDR R3, =CLK_LOW_TIME				// the low clock  time delay loop
 bit_delay14:
	  SUBS R3, R3, #1                  	// R3 -1
	  BNE bit_delay14                	// stay in loop delay1 if not equal to zero

	  LDR R3, =#(CLK_HIGH)				// set SCK high
	  STR R3, [R1, #o_GPIO_BSRR]


	  LDR  R3, [R1, #o_GPIO_IDR]	 	// sample gpio port and shift to lsb position
	  ASR  R3, #(SDA_pos+1)				// shift right into carry bit
	  ADC  R0, #0						// add carry into rx data word

	  LDR R3, =CLK_HIGH_TIME				//
 bit_delay24:
	  SUBS R3, R3, #1                  // R3 -1
	  BNE bit_delay24

	  SUBS R2, R2, #1					// dec bit count
	  BEQ  exit					// exit loop on zero bit count
	  LSL  R0, #1
	  B  loopA

 exit:
	  LDR R3,	=#(SCS_HIGH)			// Set CS high
	  STR R3, [R1, #o_GPIO_BSRR]

	  LDR R3, [R1, #o_GPIO_MODER]
	  ORR R3, #(SDA_OUT)			// Set SDA mode to output
	  STR R3, [R1, #o_GPIO_MODER]

	  BX LR                            // Return from function

	//------------------------------------------------------------------------------------------------
