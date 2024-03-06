

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
	  .equ  PULLUP,					(0x01UL<<26)
	  .equ  PULLDWN,				(0x10UL<<26)

	  .equ  COUNTER,        5000000

	  .equ  DATA_SIZE,    			8
	  .equ  CLK_HIGH_TIME,			1  // sets clock frequency
	  .equ  CLK_LOW_TIME,		    3
