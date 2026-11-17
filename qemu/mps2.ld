ENTRY(Reset_Handler)
MEMORY {
    FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 1M
    RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 192K
}
_stack_top = ORIGIN(RAM) + LENGTH(RAM);
SECTIONS {
    .vectors : { KEEP(*(.vectors)) } > FLASH
    .text : { *(.text*) *(.rodata*) . = ALIGN(4); } > FLASH
    .ARM.extab : { *(.ARM.extab*) } > FLASH
    .ARM.exidx : { __exidx_start = .; *(.ARM.exidx*) __exidx_end = .; } > FLASH
    .data : {
        . = ALIGN(4); _sdata = .;
        *(.data*) . = ALIGN(4); _edata = .;
    } > RAM AT> FLASH
    _sidata = LOADADDR(.data);
    .bss (NOLOAD) : {
        . = ALIGN(4); _sbss = .;
        *(.bss*) *(COMMON) . = ALIGN(4); _ebss = .;
    } > RAM
    end = .;
    _end = .;
    __end__ = .;
    ASSERT(_ebss + 16384 <= _stack_top, "At least 16 KiB stack space required")
}
