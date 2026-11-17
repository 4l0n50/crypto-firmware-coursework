# Hardware results

Recorded 17 November 2026 on STM32F407G-DISC1, using the supplied 1,024-byte speed.c benchmark. Learner supplied the serial output; the assistant did not independently run the board measurement. Several resets produced the same value for each version.

| Implementation | Cycles / 1,024 bytes |
|---|---:|
| Supplied C reference | 32,204 |
| Register-based assembly | 28,768 |
| Assignment maximum | 30,000 |

Saving: 3,436 cycles, or 10.67%; 1.1194x speedup. Margin below target: 1,232 cycles. Both the C reference and assembly used the same compiler settings and supplied STM32 platform. Benchmark setup selects 24 MHz, Flash zero wait states, with configured caches/prefetch. See measurements.json for tool versions and hashes of the actual firmware images used.

The reconstructed final repository's root `make firmware` produces test and speed binaries byte-for-byte identical to the recorded register-based firmware, verified during repository preparation. This claim is for the recorded compiler/toolchain; later compiler changes can change generated code and timing.

The supplied correctness test passed on hardware for the assembly. Each reconstructed snapshot was checked with the supplied regression in QEMU at -O0/-O3 and compiled for STM32. These checks do not constitute a proof of constant-time behavior or resistance to physical side-channel/fault attacks. Repeated benchmark timings use a single fixed input/key, not a secret-variation timing study.

## Instruction counts

The first assembly used 1,910 instructions per 64-byte core call. Keeping x0-x12 in r0-r12 reduced this to 1,417, saving 493 instructions (25.8%). This compares two assembly snapshots, **not** assembly against compiler-generated C. Hardware cycles above compare the supplied C against the register-based assembly. These are different comparisons.
