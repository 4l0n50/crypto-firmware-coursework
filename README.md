# ChaCha20 on ARM Cortex-M4

Self-study work for Radboud University's [Engineering Cryptographic Software, Winter 2025/26](https://cryptojedi.org/peter/teaching/engineering-crypto-software-2025.shtml). Target board: STM32F407G-DISC1. This is personal coursework, not an official course repository.

## History

The original 30 course commits are preserved unchanged through `9a245b3`. Only the added ChaCha20 development steps were reconstructed on 17 November 2026 from preserved working files. The added commits use their actual creation dates; they do not represent a contemporaneous development log. The supplied C implementation, test and benchmark are distinguished from the learner's ARM assembly and assistant-prepared build support. The register-allocation variant was prepared with AI assistance during guided study.

## Build

Install an ARM bare-metal GCC toolchain with Newlib, GNU Make, Python 3 and qemu-system-arm. For hardware use, also install stlink-tools and python3-serial. The vendored libopencm3 source and scoped python-to-python3 wrapper allow the old course platform to build without a global python alias.

```sh
make test          # supplied regression in QEMU, -O3
make test-debug    # supplied regression in QEMU, -O0
make firmware      # STM32 test and benchmark, -O3
```

Firmware appears in `build/stm32/chacha20-{test,speed}.bin`. Building does not flash the board. The supplied per-directory Makefile is retained as course material; use the root Makefile for these build commands.

## Hardware

Power/program via the Mini-USB ST-LINK port. Connect PA2 to USB-UART RXD and GND to GND; use 3.3 V logic, leave adapter power pins disconnected and remove its TX/RX loopback jumper. Open the serial monitor before flashing:

```sh
python3 -m serial.tools.miniterm /dev/ttyUSB0 115200
st-flash --reset write build/stm32/chacha20-test.bin 0x08000000
# After Test successful!, run the benchmark:
st-flash --reset write build/stm32/chacha20-speed.bin 0x08000000
```

Device names and Linux device permissions depend on the host. QEMU validates functional behavior; it does not provide STM32 hardware cycle measurements. Functional regression passes do not prove side-channel resistance.

## Sources and notices

The C reference and original test/benchmark come from the [official assignment archive](https://cryptojedi.org/peter/teaching/ecsw2025/ecsw2025-assignment.tar.bz2). The C implementation credits Daniel J. Bernstein and public-domain SUPERCOP code. Course platform files retain their original contents and notices. Vendored libopencm3 retains its source notices and `COPYING.LGPL3` / `COPYING.GPL3`; it is a dependency, not original coursework. No repository-wide license is assigned to material with differing ownership. See `PROVENANCE.json` for supplied-source hashes.

## Upstream repository

This repository imports the original ECSW Git history from https://gitlab.science.ru.nl/dis/education/ecsw. It is an import from GitLab, not a GitHub fork-network relationship. `upstream` points to Radboud and `origin` to the learner's GitHub repository. Original Poly1305, Curve25519 and other course files are retained unchanged. The added root build commands focus on ChaCha20. The original course README is preserved at docs/UPSTREAM_README.md.

## Implementation snapshots and results

After the preserved upstream course history, four added commits cover build support, the first stack-backed assembly, the register-based assembly, and hardware results. The final optimized core is chacha20/crypto_core_chacha20.s.

The optimized implementation passed the supplied hardware regression and measured **28,768 cycles for 1,024 bytes**, against **32,204** for the C reference and a **30,000-cycle** assignment target. See [results](docs/RESULTS.md), [measurement metadata](docs/measurements.json), and [hardware debugging](docs/DEBUGGING.md).
