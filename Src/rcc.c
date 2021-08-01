#include <stm32f4xx.h>

void RCC_Deinit(void)
{
    RCC->CR |= RCC_CR_HSION; // enable HSI(16mhz)
    while((RCC->CR & (RCC_CR_HSIRDY == 0))) {} // wait HSI
    RCC->CR |= 0x80U; // reset calibration
    RCC->CFGR = 0x0; // clearing the configuration register
    while ((RCC->CFGR & RCC_CFGR_SWS)) {}
    RCC->CR |= ~RCC_CR_PLLON; // disable PLL
    while((RCC->CR & RCC_CR_PLLRDY)) {}
    RCC->CR &= ~(RCC_CR_HSEON | RCC_CR_CSSON); // disable HSE and CSS
    while((RCC->CR & RCC_CR_HSERDY)) {}
    RCC->CR &= ~RCC_CR_HSEBYP;
    //Reset all CSR flags
    RCC->CSR |= RCC_CSR_RMVF;
}


#define PLL_M 12
#define PLL_N 96
#define PLL_P 2
#define PLL_Q 4

void SetSysClockTo100(void)
{
    RCC->CR |= RCC_CR_HSEON; // enable HSE
    while(!(RCC->CR & RCC_CR_HSERDY)); // wait stabilization HSE
    
    RCC->APB1ENR |= RCC_APB1ENR_PWREN;
    PWR->CR |= PWR_CR_VOS;
    RCC->CFGR |= RCC_CFGR_HPRE_DIV1; // set AHB Prescaler
    RCC->CFGR |= RCC_CFGR_PPRE1_DIV2; // set APB1 Prescaler
    RCC->CFGR |= RCC_CFGR_PPRE2_DIV1; // set APB2 Prescaler
    RCC->PLLCFGR = PLL_M | (PLL_N << 6) | (((PLL_P >> 1) -1) << 16) | (RCC_PLLCFGR_PLLSRC_HSE) | (PLL_Q << 24);
    RCC->CR |= RCC_CR_PLLON;

    while((RCC->CR & RCC_CR_PLLRDY));

    FLASH->ACR = FLASH_ACR_PRFTEN | FLASH_ACR_ICEN | FLASH_ACR_DCEN | FLASH_ACR_LATENCY_5WS;
    RCC->CFGR &= (uint32_t)((uint32_t)~RCC_CFGR_SW);
    RCC->CFGR |= RCC_CFGR_SW_PLL;

    while ((RCC->CFGR & (uint32_t)RCC_CFGR_SWS) != RCC_CFGR_SWS_PLL);
}