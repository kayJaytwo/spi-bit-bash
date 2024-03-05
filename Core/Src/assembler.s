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
  .global ASM_spi_write_byte
  .global ASM_spi_write_var
  .global ASM_spi_write_fast
  .global ASM_spi_read
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
  .equ  o_GPIO_IDR,    0x10       // offset for GPIO IDR
  .equ  o_GPIO_BSRR,   0x18       // offset for GPIO BSRR

  .equ   PERIPH_BASE,           0x40000000UL
  .equ   AHB1PERIPH_BASE,       (PERIPH_BASE + 0x00020000UL)

  .equ   GPIO_BASE,            (AHB1PERIPH_BASE + o_GPIOC)   //<- change port here
  .equ   GPIO_BSRR,            (GPIO_BASE + o_GPIO_BSRR)
  .equ   GPIO_MODER,           (GPIO_BASE + o_GPIO_MODER)
  .equ   GPIO_IDR,             (GPIO_BASE + o_GPIO_IDR)
  .equ   GPIO_PUPDR,           (GPIO_BASE + o_GPIO_PUPDR)

 .equ   SDA_MODE_pos,		26UL 							// SDA pin mode reg
 .equ 	SDA_pos,			13UL							// <- change data bit here
 .equ	SCK_pos,			14UL							// <- change clock bit here
 .equ	SCS_pos,			15UL							// <- change chip sel bit here

  .equ  SDA_BSRR,     			GPIO_BASE // GPIOC Bit set reset register
  .equ  SDA_HIGH,				(0x1UL << SDA_pos)     // SDA pin Set
  .equ  SDA_LOW,				(0x1UL<<(16+SDA_pos))  // SDA pin Clr
  .equ  CLK_LOW, 				(0x1UL<<(16+SCK_pos))
  .equ  CLK_HIGH, 				(0x1UL<<(SCK_pos))

  .equ  SCS_LOW, 				(0x1UL<<(16+SCS_pos))
  .equ  SCS_HIGH, 				(0x1UL<<(SCS_pos))

  .equ  SDA_OUT,				(0x01UL<<(SDA_MODE_pos))
  .equ  SDA_IN,				    (0x00UL<<(SDA_MODE_pos))
  .equ  SDA_MODE_mask_pos,		(0xF3FFFFFF)
  .equ  PULLUP,					(0x01UL)
  .equ  PULLDWN,				(0x10UL)
  .equ  COUNTER,        5000000

  .equ  DATA_SIZE,    			8
  .equ  CLK_HIGH_TIME,			1  // sets clock frequency
  .equ  CLK_LOW_TIME,		    3

  ASM_spi_write_byte:

//------------------------------------------------------------------------------------------------
/*
	Write variable data size packet
	data is passed in arg[1] and is in the R0  reg
	size is passed as arg[2] and is in R2 reg

   Use only registers R0-4 as these are preserved by the caller

*/
  LDR R1, =GPIO_BSRR
  LDR R2, =#DATA_SIZE


  do_1_bit:
  // Get msb bit into carry

  LSLS R0, R0, #1
  BCC  bit_zero			// branch no carry set


  LDR R3,  =#(CLK_LOW | SDA_HIGH | SCS_LOW)		//Tx bit is 1
  B write_bit

  bit_zero:   						//Tx bit is 0
   LDR R3,	=#(CLK_LOW | SDA_LOW | SCS_LOW)

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

  LDR R3,	=#(SCS_HIGH)			// Set CS high
  STR R3, [R1]

  BX LR                            // Return from function

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

//------------------------------------------------------------------------------------------------
/*
    Read 8 data bit from slave
    bit count is entered in R0
	data is return in the R0  reg
	size is passed as arg[1] and is in R0 reg

   Use only registers R0-4 as these are preserved by the caller

*/
  ASM_spi_read:
 // set port mode to input
  LDR R1, =GPIO_BASE		  // load mode register address
  // get the current gpio mode and set SDA pin to input
  LDR R2, [R1, #o_GPIO_MODER]
  LDR R3, =#(SDA_MODE_mask_pos)			//
  AND R2, R3
  STR R2, [R1, #o_GPIO_MODER]

   MOV R2,R0			// set 8 bit transfer count
   LDR R0, =#(0x0000)				// Clear RO return result reg

   loopA:

  LDR R3,  =#(CLK_LOW)		//Start low clock cycle
  STR R3, [R1, #o_GPIO_BSRR]					// write SCK low

  LDR R3, =CLK_LOW_TIME			// half the o time compared to offtime
  bit_delay14:
  SUBS R3, R3, #1                  	// R3 -1
  BNE bit_delay14                	// stay in loop delay1 if not equal to zero

  LDR R3, =#(CLK_HIGH)			// set SCK high
  STR R3, [R1, #o_GPIO_BSRR]

  // sample gpio port and shift to lsb position
  LDR  R3, [R1, #o_GPIO_IDR]					// read port bits
  AND  R3, R3, #(0x1<<SDA_pos)
  LSR  R3, #(SDA_pos)
  ORR  R0, R3

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

