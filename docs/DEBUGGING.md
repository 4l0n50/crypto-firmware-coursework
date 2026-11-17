# Debugging the STM32

Start `st-util` in one terminal (sudo only if USB permissions require it). In another:

```sh
gdb-multiarch build/stm32/chacha20-speed.elf
```

```gdb
target extended-remote localhost:4242
load
monitor reset
hbreak crypto_core_chacha20
continue
layout asm
layout regs
tui reg general
si
info registers
x/16wx $sp
```

`load` flashes the program sections from the ELF. The ELF must match the program being debugged. Macro expansion and unrolled rounds are visible in disassembly; use `si` to step one machine instruction. `push {r4-r11,lr}` is one instruction saving nine words, not a one-cycle operation. Obtain benchmark cycles from uninterrupted runs, not single-stepping.
