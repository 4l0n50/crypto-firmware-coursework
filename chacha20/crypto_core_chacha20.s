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

.macro quarterround a, b, c, d
    add                 \a, \a, \b
    eor                 \d, \d, \a
    ror                 \d, \d, #16

    add                 \c, \c, \d
    eor                 \b, \b, \c
    ror                 \b, \b, #20

    add                 \a, \a, \b
    eor                 \d, \d, \a
    ror                 \d, \d, #24

    add                 \c, \c, \d
    eor                 \b, \b, \c
    ror                 \b, \b, #25
.endm

// Load a word into dst and save its initial value as j[index].
// Saving the working x value is explicit at the call site.
.macro init_word dst, base, offset, index, tmp
    load_littleendian   \dst, \base, \offset, \tmp
    str                 \dst, [sp, #(64+4* \index)]
.endm

crypto_core_chacha20:
    // Arguments arrive in registers:
    // r0 = out
    // r1 = in
    // r2 = k
    // r3 = c

    // Preserve the caller's registers.
    push                {r4-r11, lr}
    // 128 bytes of state plus the saved output pointer.
    // Together with the 36-byte push, this keeps sp 8-byte aligned.
    sub                 sp, sp, #132
    str                 r0, [sp, #128] // Save out for the final stores.

    // Constants: x0–x3 and j0–j3.
.irp i, 0, 1, 2, 3
    init_word           r4, r3, (4*\i), \i, r5
    str                 r4, [sp, #(4*\i)]
.endr

    // Key: x4–x11 and j4–j11.
.irp i, 0, 1, 2, 3, 4, 5, 6, 7
    init_word           r4, r2, (4*\i), (\i+4), r5
    str                 r4, [sp, #(4*(\i+4))]
.endr

    // Input: x12–x15 and j12–j15.
    init_word           r4, r1, 8, 12, r5
    str                 r4, [sp, #48]
    init_word           r4, r1, 12, 13, r5
    str                 r4, [sp, #52]
    init_word           r4, r1, 0, 14, r5
    str                 r4, [sp, #56]
    init_word           r4, r1, 4, 15, r5
    str                 r4, [sp, #60]

    // Fixed mapping during the rounds: x0-x12 live in r0-r12.
    // x13-x15 live at sp+52, sp+56, sp+60; lr is their scratch register.
    // All input pointers are dead now; out and the return address are saved.
    ldr                 r0, [sp, #0] // x0
    ldr                 r1, [sp, #4] // x1
    ldr                 r2, [sp, #8] // x2
    ldr                 r3, [sp, #12] // x3
    ldr                 r4, [sp, #16] // x4
    ldr                 r5, [sp, #20] // x5
    ldr                 r6, [sp, #24] // x6
    ldr                 r7, [sp, #28] // x7
    ldr                 r8, [sp, #32] // x8
    ldr                 r9, [sp, #36] // x9
    ldr                 r10, [sp, #40] // x10
    ldr                 r11, [sp, #44] // x11
    ldr                 r12, [sp, #48] // x12

.rept ROUNDS/2
    // Column phase.
    quarterround        r0, r4, r8, r12       // x0, x4, x8, x12

    ldr                 lr, [sp, #52]       // x13
    quarterround        r1, r5, r9, lr
    str                 lr, [sp, #52]       // Updated x13

    ldr                 lr, [sp, #56]       // x14
    quarterround        r2, r6, r10, lr
    str                 lr, [sp, #56]

    ldr                 lr, [sp, #60]       // x15
    quarterround        r3, r7, r11, lr
    str                 lr, [sp, #60]

    // Diagonal phase.
    ldr                 lr, [sp, #60]       // x15
    quarterround        r0, r5, r10, lr
    str                 lr, [sp, #60]

    quarterround        r1, r6, r11, r12     // x1, x6, x11, x12

    ldr                 lr, [sp, #52]       // x13
    quarterround        r2, r7, r8, lr
    str                 lr, [sp, #52]

    ldr                 lr, [sp, #56]       // x14
    quarterround        r3, r4, r9, lr
    str                 lr, [sp, #56]
.endr

    // Save the resident words before reusing registers for final output.
    str                 r0, [sp, #0] // x0
    str                 r1, [sp, #4] // x1
    str                 r2, [sp, #8] // x2
    str                 r3, [sp, #12] // x3
    str                 r4, [sp, #16] // x4
    str                 r5, [sp, #20] // x5
    str                 r6, [sp, #24] // x6
    str                 r7, [sp, #28] // x7
    str                 r8, [sp, #32] // x8
    str                 r9, [sp, #36] // x9
    str                 r10, [sp, #40] // x10
    str                 r11, [sp, #44] // x11
    str                 r12, [sp, #48] // x12

    ldr                 r0, [sp, #128] // Recover out before writing results.
.irp i, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
    ldr                 r4, [sp, #(4*\i)]
    ldr                 r5, [sp, #(64+4*\i)]
    add                 r4, r4, r5
    store_littleendian  r0, (4*\i), r4
.endr

    movs                r0, #0 // Return value: int 0.

    add                 sp, sp, #132
    pop                 {r4-r11, pc} // Restore registers and return.

.size crypto_core_chacha20, .-crypto_core_chacha20
