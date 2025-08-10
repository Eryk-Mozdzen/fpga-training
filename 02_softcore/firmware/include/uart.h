#ifndef UART_H
#define UART_H

char uart_getc();
unsigned int uart_geth();
void uart_putc(char ch);
void uart_puts(char *str);
void uart_puth(unsigned int val);

#endif
