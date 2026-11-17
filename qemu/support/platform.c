#include "../../common/ecsw.h"
extern void qemu_exit(int status) __attribute__((noreturn));

void output(char *message)
{
    register unsigned int r0 __asm__("r0") = 4u; /* SYS_WRITE0 */
    register const char *r1 __asm__("r1") = message;
    __asm__ volatile("bkpt 0xab" : "+r"(r0), "+r"(r1) : : "memory");
}
void setup(const enum ecsw_mode mode)
{
    if (mode != ECSW_TEST)
    {
        output("QEMU: hardware cycle benchmarking is unavailable.\n");
        qemu_exit(2);
    }
}
/* Let the original main return, so its failure status reaches the host. */
void teardown(void) {}
unsigned long long performance_count(void)
{
    output("QEMU: refusing to report simulated instructions as hardware cycles.\n");
    qemu_exit(2);
}
char *performance_count_unit(void) { return "unavailable-in-QEMU"; }
