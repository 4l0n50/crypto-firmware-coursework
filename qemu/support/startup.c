#include <stdint.h>
extern uint32_t _stack_top, _sidata, _sdata, _edata, _sbss, _ebss;
extern int main(void);
extern void initialise_monitor_handles(void);
void qemu_exit(int status) __attribute__((noreturn));
void Reset_Handler(void);
void Default_Handler(void);

void qemu_exit(int status)
{
    /* Arm semihosting SYS_EXIT_EXTENDED, with explicit process status. */
    const uint32_t args[2] = {0x20026u, (uint32_t)status};
    register uint32_t r0 __asm__("r0") = 0x20u;
    register const uint32_t *r1 __asm__("r1") = args;
    __asm__ volatile("bkpt 0xab" : "+r"(r0), "+r"(r1) : : "memory");
    for (;;) {}
}
void Default_Handler(void) { qemu_exit(125); }
void Reset_Handler(void)
{
    volatile uint32_t *cpacr = (volatile uint32_t *)0xe000ed88u;
    *cpacr |= 0xfu << 20;
    __asm__ volatile("dsb\nisb" ::: "memory");
    uint32_t *src = &_sidata;
    for (uint32_t *dst = &_sdata; dst < &_edata;) *dst++ = *src++;
    for (uint32_t *dst = &_sbss; dst < &_ebss;) *dst++ = 0;
    initialise_monitor_handles();
    qemu_exit(main());
}
__attribute__((section(".vectors"), used))
void (* const vectors[16])(void) = {
    (void (*)(void))&_stack_top, Reset_Handler,
    Default_Handler, Default_Handler, Default_Handler, Default_Handler,
    Default_Handler, 0, 0, 0, 0, Default_Handler,
    Default_Handler, 0, Default_Handler, Default_Handler
};
