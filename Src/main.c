#include <stm32f4xx.h>
#include "rcc.c"

void __libc_init_array(void){};

void _init(void);
void SystemInit(){};

void delay(uint32_t ms)
{
    for(uint32_t nops = 0; nops < ms*260UL; nops++)
        __asm("nop");
    return;
}

int main(void)
{
    RCC_Deinit();
    SetSysClockTo100();
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOCEN;
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
    GPIOA->MODER = 0x0;
    GPIOC->MODER = 0x04000000;
    GPIOC->OTYPER = 0;
    GPIOC->OSPEEDR = 0x0C000000;
    while(1)
    {
        GPIOC->ODR = 0x2000;
        delay(1000);
        GPIOC->ODR = 0x0000;
        delay(1000);
    }
}
