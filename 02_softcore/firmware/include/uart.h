#ifndef UART_H
#define UART_H

void uart_set_div(unsigned int div);
void uart_print_hex(unsigned int val);
char uart_getchar(void);
void uart_putchar(char ch);
void uart_puts(char *s);
unsigned int uart_get_hex(void);

#endif
