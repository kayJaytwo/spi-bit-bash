/*
 * assembler.h
 *
 *  Created on: Mar 2, 2024
 *      Author: Ken
 */

#ifndef INC_ASSEMBLER_H_
#define INC_ASSEMBLER_H_

extern void ASM_Function(void);
extern void ASM_spi_write_byte(uint32_t  data);
extern void ASM_spi_write_var(uint32_t  data, uint32_t size);
extern void ASM_spi_write_fast(uint32_t  data, uint32_t size);
extern uint32_t ASM_spi_read(uint32_t size);
#endif /* INC_ASSEMBLER_H_ */
