.syntax unified
.cpu cortex-m4
.thumb

.text
.global crypto_core_chacha20
.type crypto_core_chacha20, %function
.thumb_func

    .equ ROUNDS, 20

.macro load_littleendian dst, base, offset, tmp
    ldrb                \dst, [\base, #(\offset)]

    ldrb                \tmp, [\base, #(\offset+1)]
    orr                 \dst, \dst, \tmp, lsl#8

    ldrb                \tmp, [\base, #(\offset+2)]
    orr                 \dst, \dst, \tmp, lsl#16

    ldrb                \tmp, [\base, #(\offset+3)]
    orr                 \dst, \dst, \tmp, lsl#24
.endm

.macro store_littleendian dst, offset, src
    strb                \src, [\dst, #(\offset+0)]
    lsr                 \src, \src, #8
    strb                \src, [\dst, #(\offset+1)]
    lsr                 \src, \src, #8
    strb                \src, [\dst, #(\offset+2)]
    lsr                 \src, \src, #8
    strb                \src, [\dst, #(\offset+3)]
.endm

.macro quarterround base, a, b, c, d
    ldr                 r4, [\base, #(\a)]
    ldr                 r5, [\base, #(\b)]
    ldr                 r6, [\base, #(\c)]
    ldr                 r7, [\base, #(\d)]

    add                 r4, r4, r5
    eor                 r7, r7, r4
    ror                 r7, r7, #16 // 32 - 16

    add                 r6, r6, r7
    eor                 r5, r5, r6
    ror                 r5, r5, #20 // 32 - 12

    add                 r4, r4, r5
    eor                 r7, r7, r4
    ror                 r7, r7, #24 // 32 - 8

    add                 r6, r6, r7
    eor                 r5, r5, r6
    ror                 r5, r5, #25 // 32 - 7

    str                 r4, [\base, #(\a)]
    str                 r5, [\base, #(\b)]
    str                 r6, [\base, #(\c)]
    str                 r7, [\base, #(\d)]
.endm

// index identifies xindex and jindex.
.macro init_word base, offset, index
    load_littleendian   r4, \base, \offset, r5
    str                 r4, [sp, #(4* \index)]
    str                 r4, [sp, #(64+4* \index)]
.endm

crypto_core_chacha20:
    // Arguments arrive in registers:
    // r0 = out
    // r1 = in
    // r2 = k
    // r3 = c

    // Preserve the caller's registers.
    push                {r4-r7}
    sub                 sp, sp, #128 // Store x0,...x15, j0, ..., j15

    // Constants: x0–x3 and j0–j3.
.irp i, 0, 1, 2, 3
    init_word           r3, (4*\i), \i
.endr

    // Key: x4–x11 and j4–j11.
.irp i, 0, 1, 2, 3, 4, 5, 6, 7
    init_word           r2, (4*\i), (\i+4)
.endr

    // Input: x12–x15 and j12–j15.
    init_word           r1, 8, 12
    init_word           r1, 12, 13
    init_word           r1, 0, 14
    init_word           r1, 4, 15

.rept ROUNDS/2
    quarterround        sp, (4*0), (4*4), (4*8), (4*12)
    quarterround        sp, (4*1), (4*5), (4*9), (4*13)
    quarterround        sp, (4*2), (4*6), (4*10), (4*14)
    quarterround        sp, (4*3), (4*7), (4*11), (4*15)
    quarterround        sp, (4*0), (4*5), (4*10), (4*15)
    quarterround        sp, (4*1), (4*6), (4*11), (4*12)
    quarterround        sp, (4*2), (4*7), (4*8), (4*13)
    quarterround        sp, (4*3), (4*4), (4*9), (4*14)
.endr

.irp i, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
    ldr                 r4, [sp, #(4*\i)]
    ldr                 r5, [sp, #(64+4*\i)]
    add                 r4, r4, r5
    store_littleendian  r0, (4*\i), r4
.endr

    movs                r0, #0 // Return value: int 0.

    add                 sp, sp, #128
    pop                 {r4-r7}// Restore registers.
    bx                  lr

.size crypto_core_chacha20, .-crypto_core_chacha20
