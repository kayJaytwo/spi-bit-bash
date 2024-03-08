	/*
	 * assembler.s
	 *
	 *  Created on: Mar 2, 2024
	 *      Author: Ken
	 */

	  .syntax unified

	  .text
	  .thumb_func


	//------------------------------------------------------------------------------------------------
	/*  Include  the definitions file for the GPIO registers and bit fields
	*/
	#include "asm_defines.s"

	//------------------------------------------------------------------------------------------------
	/*
	include the assembly files for each function
	*/
	#include "spi_read.s"
//	#include "asm_spi_write.s"
//	#include "asm_spi_write_fast.s"
	#include "asm_spi_write_var.s"
//	#include "asm_spi_command_wr.s"

