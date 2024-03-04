/*
 * assembler.s
 *
 *  Created on: Mar 2, 2024
 *      Author: Ken
 */


/*
 * assembler.s
 *
 */

  .syntax unified

  .text
  .global ASM_SystemInit
  .global ASM_Function
  .global ASM_spi_write_byte
  .global ASM_spi_write_var
  .global ASM_spi_write_fast
  .thumb_func


/* STM32F401 peripheral address map
0x4002 1C00 - 0x4002 1FFF GPIOH
Section 8.4.11: GPIO register map on page 164
0x4002 1000 - 0x4002 13FF GPIOE
0x4002 0C00 - 0x4002 0FFF GPIOD
0x4002 0800 - 0x4002 0BFF GPIOC
0x4002 0400 - 0x4002 07FF GPIOB
0x4002 0000 - 0x4002 03FF GPIOA
*/

  .equ  o_GPIOA, 	0x0000UL
  .equ  o_GPIOB, 	0x0400UL
  .equ  o_GPIOC, 	0x0800UL
  .equ  o_GPIOD, 	0x0C00UL
  .equ  o_GPIOE, 	0x1000UL
  .equ  o_GPIOH, 	0x1C00UL


 /*define the map offsets for GPIO registers */
  .equ  o_GPIO_MODER,  0x00       // offset to GPIO_MODER
  .equ  o_GPIO_OTYPER, 0x04       // offset for GPIO Output PP/OD
  .equ  o_GPIO_OSPEEDR,0x08       // offset for GPIO Output Speed
  .equ  o_GPIO_PUPDR,  0x0C       // offset for GPIO PU/PD
  .equ  o_GPIO_BSRR,   0x18       // offset for GPIO BSRR

  .equ   PERIPH_BASE,           0x40000000UL
  .equ   AHB1PERIPH_BASE,       (PERIPH_BASE + 0x00020000UL)
  .equ   GPIOC_BASE,            (AHB1PERIPH_BASE + o_GPIOC)   //<- change port here
  .equ   GPIO_BSRR,             (GPIOC_BASE + o_GPIO_BSRR)

 .equ 	SDA_pos,			13UL							// <- change data bit here
 .equ	SCK_pos,			14UL							// <- change clock bit here

  .equ  SDA_BSRR,     			GPIO_BASE // GPIOC Bit set reset register
  .equ  SDA_HIGH,				(0x1UL << SDA_pos)     // SDA pin Set
  .equ  SDA_LOW,				(0x1UL<<(16+SDA_pos))  // SDA pin Clr
  .equ  CLK_LOW, 				(0x1UL<<(16+SCK_pos))
  .equ  CLK_HIGH, 				(0x1UL<<(SCK_pos))
  .equ  COUNTER,        5000000


//------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------
  ASM_Function:

  turnON:
  // Set output high
  LDR R1, =GPIO_BSRR
  LDR R0, =#SDA_HIGH
  STR R0, [R1]

  LDR R2, =COUNTER>>2				// half the o time compared to offtime
  delay1:
  SUBS R2, R2, #1                  // R2 = R2 - 1, R2 = 0?
  BNE delay1                       // stay in loop delay1 if not equal to zero

  turnOFF:
  // Set output low
  LDR R0, =#SDA_LOW
  STR R0, [R1]
  LDR R2, =#COUNTER

  delay2:
  SUBS R2, R2, #1                  // R2 = R2 - 1, R2 = 0?
  BNE delay2                       // stay in loop delay1 if not equal to zero

  delayDone:
  B turnON                         // Jump to turnON

//------------------------------------------------------------------------------------------------
// define data patterns for clock and data
  .equ  BIT_SET_CLK_HIGH,		0x00006000  // Set Data bit
  .equ  BIT_CLR_CLK_HIGH,		(0x2000<<16UL)| 0x4000  // Clear Data bit
  .equ  DATA_SIZE,    			8
  .equ  CLK_HIGH_TIME,			4  // sets clock frequency
  .equ  CLK_LOW_TIME,		    4


  ASM_spi_write_byte:

// Use registers R0-4 as these are preserved by the caller
// data byte for tx is passed in R0
  LDR R1, =GPIO_BSRR
  LDR R2, =#DATA_SIZE


  do_1_bit:
  // Get msb bit into carry

  LSLS R0, R0, #1
  BCC  bit_zero			// branch no carry set


  LDR R3,  =#(CLK_LOW | SDA_HIGH)		//Tx bit is 1
  B write_bit

  bit_zero:   						//Tx bit is 0
   LDR R3,	=#(CLK_LOW | SDA_LOW )

  write_bit:
    STR R3, [R1]					// write SCK high and data on SDA

  LDR R3, =CLK_LOW_TIME			// half the o time compared to offtime
  bit_delay1:
  SUBS R3, R3, #1                  	// R3 -1
  BNE bit_delay1                	// stay in loop delay1 if not equal to zero

  LDR R3, =#(CLK_HIGH)			// set SCK low and keep data on SDA
  STR R3, [R1]

  LDR R3, =CLK_HIGH_TIME				//
  bit_delay2:
  SUBS R3, R3, #1                  // R3 -1
  BNE bit_delay2


  SUBS R2, R2, #1
  BNE do_1_bit

  BX LR                            // Return from function

//------------------------------------------------------------------------------------------------
/*
	Write variable data size packet
	size is passed as arg[2] and is in R2 register on entry
*/

/*
  .equ  BIT_SET_CLK_HIGH,		0x00006000  // Set Data bit
  .equ  BIT_CLR_CLK_HIGH,		(0x2000<<16UL)| 0x4000  // Clear Data bit
  .equ  CLK_HIGH_TIME,			1    // sets clock frequency
  .equ  CLK_LOW_TIME,		    1
*/

  ASM_spi_write_var:

// Use registers R0-4 as these are preserved by the caller
// data byte for tx is passed in R0
  LDR R2, =GPIO_BSRR

  do_1_bit2:
  // Get msb bit into carry

  LSLS R0, R0, #1
  BCC  bit_zero2			// branch no carry set


  LDR R3,	=#(CLK_LOW | SDA_HIGH)		//Tx bit is 1
  B write_bit2

  bit_zero2:   						//Tx bit is 0
   LDR R3,	=#(CLK_LOW | SDA_LOW)

  write_bit2:
    STR R3, [R2]					// write SCK low and data on SDA

  LDR R3, =CLK_LOW_TIME			// half the o time compared to offtime

  bit_delay12:
  SUBS R3, R3, #1                  	// R3 -1
  BNE bit_delay12                	// stay in loop delay1 if not equal to zero

  LDR R3, =#(CLK_HIGH )				// set SCK high and keep data on SDA
  STR R3, [R2]

  LDR R3, =CLK_HIGH_TIME			//

  bit_delay22:
  SUBS R3, R3, #1                  // R3 -1
  BNE bit_delay22

  SUBS R1, R1, #1					// decrement bit count branch if not zero
  BNE do_1_bit2

  BX LR                            // Return from function

  //------------------------------------------------------------------------------------------------
/*
	Write variable data size packet
	size is passed as arg[2] and is in R1 register on entry
	This is a no delay routine, therefore represents the fastest
	clock & data rate possible at the given master clock frequency.

*/

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

