//*******************************************************************************************
// SIDH: an efficient supersingular isogeny cryptography library
//
// Abstract: field arithmetic in 64-bit ARMv8 assembly for P377 on Linux
//*******************************************************************************************

.text

// p377
p377:
.quad  0xFFFFFFFFFFFFFFFF
.quad  0x7FFFFFFFFFFFFFFF
.quad  0x0B46D546BC2A5699
.quad  0xA879CC6988CE7CF5
.quad  0x015B702E0C542196

// 2 * p377
p377x2:
.quad  0xFFFFFFFFFFFFFFFE
.quad  0xFFFFFFFFFFFFFFFF
.quad  0x168DAA8D7854AD32
.quad  0x50F398D3119CF9EA
.quad  0x02B6E05C18A8432D

// 4 * p377
p377x4:
.quad  0xFFFFFFFFFFFFFFFC
.quad  0xFFFFFFFFFFFFFFFF 
.quad  0x2D1B551AF0A95A65 
.quad  0xA1E731A62339F3D4
.quad  0x056DC0B83150865A

p377p1x2:
.quad  0x168DAA8D7854AD33
.quad  0x50F398D3119CF9EA
.quad  0x02B6E05C18A8432D


//***********************************************************************
//  Field addition
//  Operation: c [x2] = a [x0] + b [x1]
//*********************************************************************** 
.global fpadd377_asm
fpadd377_asm:

    // Add a + b
    ldp     x3, x4,   [x0,#0]
    ldp     x11, x12, [x1,#0]
    ldp     x5, x6,   [x0,#16]
    ldp     x13, x14, [x1,#16]
    ldp     x7, x8,   [x0,#32]
    ldp     x15, x16, [x1,#32]
    adds    x3, x3, x11
    adcs    x4, x4, x12
    adcs    x5, x5, x13
    adcs    x6, x6, x14
    ldr     x11, p377x2
    adcs    x7, x7, x15
    ldr     x12, p377x2 + 8
    adc     x8, x8, x16
    ldr     x13, p377x2 + 16
    
    //  Subtract 2xp377
    subs    x3, x3, x11
    ldr     x14, p377x2 + 24
    sbcs    x4, x4, x12
    ldr     x15, p377x2 + 32
    sbcs    x5, x5, x12
    sbcs    x6, x6, x13
    sbcs    x7, x7, x14
    sbcs    x8, x8, x15
    sbc     x10, xzr, xzr

    // Add 2xp377 anded with the mask in x10
    and     x11, x11, x10 
    and     x12, x12, x10 
    and     x13, x13, x10 
    and     x14, x14, x10 
    and     x15, x15, x10  

    adds    x3, x3, x11
    adcs    x4, x4, x12
    stp     x3, x4,  [x2,#0]
    adcs    x5, x5, x12
    adcs    x6, x6, x13
    stp     x5, x6,  [x2,#16]
    adcs    x7, x7, x14
    adc     x8, x8, x15 
    stp     x7, x8,  [x2,#32]
    ret


//***********************************************************************
//  Field subtraction
//  Operation: c [x2] = a [x0] - b [x1]
//*********************************************************************** 
.global fpsub377_asm
fpsub377_asm:

    // Subtract a - b
    ldp     x3, x4,   [x0,#0]
    ldp     x11, x12, [x1,#0]
    ldp     x5, x6,   [x0,#16]
    ldp     x13, x14, [x1,#16]
    ldp     x7, x8,   [x0,#32]
    ldp     x15, x16, [x1,#32]
    subs    x3, x3, x11
    sbcs    x4, x4, x12
    sbcs    x5, x5, x13
    ldr     x11, p377x2
    sbcs    x6, x6, x14
    ldr     x12, p377x2 + 8
    sbcs    x7, x7, x15
    ldr     x13, p377x2 + 16
    sbcs    x8, x8, x16
    ldr     x14, p377x2 + 24
    sbc     x10, xzr, xzr
    
    // Add 2xp377 anded with the mask in x10
    ldr     x15, p377x2 + 32
    and     x11, x11, x10 
    and     x12, x12, x10 
    and     x13, x13, x10
    and     x14, x14, x10 
    and     x15, x15, x10  

    adds    x3, x3, x11
    adcs    x4, x4, x12
    stp     x3, x4,  [x2,#0]
    adcs    x5, x5, x12
    adcs    x6, x6, x13
    stp     x5, x6,  [x2,#16]
    adcs    x7, x7, x14
    adc     x8, x8, x15 
    stp     x7, x8,  [x2,#32]
    ret


///////////////////////////////////////////////////////////////// MACRO
.macro SUB377_PX  P0

    // Subtract a - b
    ldp     x3, x4,   [x0,#0]
    ldp     x11, x12, [x1,#0]
    ldp     x5, x6,   [x0,#16]
    ldp     x13, x14, [x1,#16]
    ldp     x7, x8,   [x0,#32]
    ldp     x15, x16, [x1,#32]
    subs    x3, x3, x11
    sbcs    x4, x4, x12
    sbcs    x5, x5, x13
    ldr     x11, \P0
    sbcs    x6, x6, x14
    ldr     x12, \P0 + 8
    sbcs    x7, x7, x15
    ldr     x13, \P0 + 16 
    sbc     x8, x8, x16

    ldr     x14, \P0 + 24  
    adds    x3, x3, x11  
    ldr     x15, \P0 + 32
    adcs    x4, x4, x12
    stp     x3, x4,  [x2,#0]
    adcs    x5, x5, x12
    adcs    x6, x6, x13
    stp     x5, x6,  [x2,#16]
    adcs    x7, x7, x14
    adc     x8, x8, x15 
    stp     x7, x8,  [x2,#32]
  .endm


//***********************************************************************
//  Multiprecision subtraction with correction with 2*p377
//  Operation: c [reg_p3] = a [reg_p1] - b [reg_p2] + 2*p377
//*********************************************************************** 
.global mp_sub377_p2_asm
mp_sub377_p2_asm:

  SUB377_PX  p377x2
  ret


//***********************************************************************
//  Multiprecision subtraction with correction with 4*p377
//  Operation: c [reg_p3] = a [reg_p1] - b [reg_p2] + 4*p377
//*********************************************************************** 
.global mp_sub377_p4_asm
mp_sub377_p4_asm:

  SUB377_PX  p377x4
  ret

	
//////////////////////////////////////////// MACRO
.macro MUL192_COMBA  A0, A1, A2, B0, B1, B2, C0, C1, C2, C3, C4, C5, T0, T1
    mul     \C0, \A0, \B0       
    umulh   \C3, \A0, \B0 
    mul     \C1, \A0, \B1
    umulh   \C2, \A0, \B1

    mul     \C4, \A1, \B0
    umulh   \C5, \A1, \B0
    adds    \C1, \C1, \C3
    adc     \C2, \C2, xzr
    
    mul     \T1, \A1, \B1
    umulh   \C3, \A1, \B1
    adds    \C1, \C1, \C4
    adcs    \C2, \C2, \C5
    adc     \C3, \C3, xzr
    
    mul     \C4, \A0, \B2
    umulh   \C5, \A0, \B2
    adds    \C2, \C2, \T1
    adcs    \C3, \C3, \C5
    adc     \T0, xzr, xzr
    
    mul     \T1, \A2, \B0
    umulh   \C5, \A2, \B0
    adds    \C2, \C2, \C4
    adcs    \C3, \C3, \C5
    adc     \T0, \T0, xzr
    
    mul     \C4, \A1, \B2
    umulh   \C5, \A1, \B2
    adds    \C2, \C2, \T1
    adcs    \C3, \C3, \C4
    adcs    \T0, \T0, \C5
    adc     \T1, xzr, xzr
    
    mul     \C4, \A2, \B1
    umulh   \C5, \A2, \B1
    adds    \C3, \C3, \C4
    adcs    \T0, \T0, \C5
    adc     \T1, \T1, xzr
    
    mul     \C4, \A2, \B2
    umulh   \C5, \A2, \B2
    adds    \C4, \C4, \T0
    adc     \C5, \C5, \T1
.endm


//***********************************************************************************
//  384-bit integer multiplication using Karatsuba (upper level), Comba (lower level)
//  Operation: c [x2] = a [x0] * b [x1]
//*********************************************************************************** 
.global mul377_asm
mul377_asm:
    sub     sp, sp, #96
    ldp     x3, x4, [x0]
    ldp     x5, x6, [x0,#16]
    ldp     x7, x8, [x0,#32]
    stp     x25, x26, [sp,#48]
    stp     x27, x28, [sp,#64]
    stp     x29, x30, [sp,#80]

    // x26-x28 <- AH + AL, x17 <- mask
    adds    x26, x3, x6
    ldp     x11, x12, [x1,#0]
    adcs    x27, x4, x7
    ldp     x15, x16, [x1,#32]
    adcs    x28, x5, x8
    ldp     x13, x14, [x1,#16]
    adc     x17, xzr, xzr
    stp     x19, x20, [sp,#0]

    // x11-x13 <- BH + BL, x19 <- mask
    adds    x11, x11, x14
    adcs    x12, x12, x15
    stp     x21, x22, [sp,#16]
    adcs    x13, x13, x16
    stp     x23, x24, [sp,#32]
    adc     x19, xzr, xzr
    
    // x14-x16 <- masked (BH + BL)
    sub     x17, xzr, x17
    sub     x19, xzr, x19
    and     x14, x11, x17
    and     x15, x12, x17
    and     x16, x13, x17

    // x19-x21 <- masked (AH + AL)
    and     x20, x27, x19
    and     x21, x28, x19
    and     x19, x26, x19

    // x14-x16 <- masked (AH+AL) + masked (BH+BL), step 1
    adds    x14, x14, x19
    adcs    x15, x15, x20
    adc     x16, x16, x21
    
    // x9-x10, x17, x19-x21 <- (AH+AL) x (BH+BL), low part
    MUL192_COMBA  x26, x27, x28, x11, x12, x13, x9, x10, x17, x19, x20, x21, x29, x30  
    
    // x9-x10, x17, x19-x21 <- (AH+AL) x (BH+BL), final step
    adds    x19, x19, x14
    ldp     x11, x12, [x1,#0]
    adcs    x20, x20, x15
    adc     x21, x21, x16
    ldr     x13, [x1,#16]

    // x14-x16, x22-x24 <- AL x BL
    MUL192_COMBA  x3, x4, x5, x11, x12, x13, x14, x15, x16, x22, x23, x24, x29, x30
    
    // x9-x10, x17, x19-x21 <- (AH+AL) x (BH+BL) - ALxBL
    subs    x9, x9, x14 
    sbcs    x10, x10, x15
    stp     x14, x15, [x2]        // Output c0-c2
    ldr     x11,      [x1,#24]
    sbcs    x17, x17, x16
    sbcs    x19, x19, x22
    str     x16, [x2,#16]
    ldp     x12, x13, [x1,#32]
    sbcs    x20, x20, x23
    sbc     x21, x21, x24

    // x14-x16, x3-x5 <- AH x BH
    MUL192_COMBA  x6, x7, x8, x11, x12, x13, x14, x15, x16, x3, x4, x5, x29, x30
    
    // x9-x10, x17, x19-x21 <- (AH+AL) x (BH+BL) - ALxBL - AHxBH
    subs    x9, x9, x14 
    sbcs    x10, x10, x15
    ldp     x25, x26, [sp,#48]
    sbcs    x17, x17, x16
    sbcs    x19, x19, x3  
    ldp     x29, x30, [sp,#80]
    sbcs    x20, x20, x4
    sbc     x21, x21, x5

    adds    x9, x9, x22
    str     x9,   [x2,#24]        // Output c3-c11
    adcs    x10, x10, x23 
    ldp     x27, x28, [sp,#64]    
    adcs    x17, x17, x24
    stp     x10, x17, [x2,#32]  
    adcs    x19, x19, x14  
    ldp     x23, x24, [sp,#32] 
    adcs    x20, x20, x15 
    stp     x19, x20, [x2,#48]        
    adcs    x21, x21, x16
    ldp     x19, x20, [sp,#0]
    adcs    x3, x3, xzr
    stp     x21, x3, [x2,#64] 
    adcs    x4, x4, xzr
    ldp     x21, x22, [sp,#16]
    adc     x5, x5, xzr
    stp     x4, x5, [x2,#80]
    add     sp, sp, #96
    ret
    
        
//////////////////////////////////////////// MACRO
.macro MUL128x192_COMBA_CUT  A0, A1, B0, B1, B2, C0, C1, C2, C3, C4, T0, T1, T2
    mul     \T0, \A1, \B0
    umulh   \T1, \A1, \B0 
    adds    \C1, \C1, \C3
    adc     \C2, \C2, xzr 

    mul     \T2, \A0, \B2
    umulh   \C3, \A0, \B2 
    adds    \C1, \C1, \T0
    adcs    \C2, \C2, \T1
    adc     \C3, \C3, xzr
    
    mul     \T0, \A1, \B1
    umulh   \T1, \A1, \B1    
    adds    \C2, \C2, \T2
    adcs    \C3, \C3, \T1
    adc     \C4, xzr, xzr
    
    mul     \T1, \A1, \B2
    umulh   \T2, \A1, \B2 
    adds    \C2, \C2, \T0
    adcs    \C3, \C3, \T1
    adc     \C4, \C4, \T2
.endm


//**************************************************************************************
//  Montgomery reduction
//  Based on method described in Faz-Hernandez et al. https://eprint.iacr.org/2017/1015  
//  Operation: mc [x1] = ma [x0]
//  NOTE: ma=mc is not allowed
//************************************************************************************** 
.global rdc377_asm
rdc377_asm:
    sub     sp, sp, #48
    stp     x19, x20, [sp]
    stp     x21, x22, [sp,#16]
    ldp     x2, x3, [x0,#0]       // a[0-1]

    // Load the prime constant
    ldr     x19, p377p1x2 + 0
    ldr     x20, p377p1x2 + 8

    // a[0-1] x 2xp377p1_nz --> result: x4:x8
    mul     x4, x2, x19           // a[0] x p377p1x2[0]
    umulh   x7, x2, x19  
    stp     x23, x24, [sp,#32] 
    ldr     x21, p377p1x2 + 16     
    mul     x5, x2, x20           // a[0] x p377p1x2[1]
    umulh   x6, x2, x20     
    ldp     x10, x11, [x0,#32]
    ldp     x12, x13, [x0,#48] 
    MUL128x192_COMBA_CUT x2, x3, x19, x20, x21, x4, x5, x6, x7, x8, x22, x23, x24   
	
    ldp     x2, x3, [x0,#16]
    orr     x9, xzr, x8, lsr #1
    lsl     x8, x8, #63
    orr     x8, x8, x7, lsr #1
    lsl     x7, x7, #63
    orr     x7, x7, x6, lsr #1
    lsl     x6, x6, #63  
    orr     x6, x6, x5, lsr #1
    lsl     x5, x5, #63  
    orr     x5, x5, x4, lsr #1
    lsl     x4, x4, #63
    
    adds    x2, x4, x2            // a[2-3]
    adcs    x3, x5, x3          
    ldp     x14, x15, [x0,#64]  
    adcs    x10, x6, x10
    adcs    x11, x7, x11  
    ldp     x16, x17, [x0,#80]  
    adcs    x12, x8, x12 
    mul     x4, x2, x19           // a[2] x p377p1x2[0]
    umulh   x7, x2, x19  
    adcs    x13, x9, x13
    adcs    x14, xzr, x14 
    adcs    x15, xzr, x15      
    mul     x5, x2, x20           // a[3] x p377p1x2[1]
    umulh   x6, x2, x20     
    adcs    x16, xzr, x16 
    adc     x17, xzr, x17

    // a[2-3] x 2xp377p1_nz --> result: x4:x8
    MUL128x192_COMBA_CUT x2, x3, x19, x20, x21, x4, x5, x6, x7, x8, x22, x23, x24   

    orr     x9, xzr, x8, lsr #1
    lsl     x8, x8, #63
    orr     x8, x8, x7, lsr #1
    lsl     x7, x7, #63
    orr     x7, x7, x6, lsr #1
    lsl     x6, x6, #63  
    orr     x6, x6, x5, lsr #1
    lsl     x5, x5, #63  
    orr     x5, x5, x4, lsr #1
    lsl     x4, x4, #63 
    
    adds    x2, x4, x10           // a[4-5]
    adcs    x3, x5, x11 
    adcs    x12, x6, x12
    adcs    x13, x7, x13    
    mul     x4, x2, x19           // a[4] x p377p1x2[0]
    umulh   x7, x2, x19  
    adcs    x14, x8, x14
    adcs    x15, x9, x15    
    mul     x5, x2, x20           // a[5] x p377p1x2[1]
    umulh   x6, x2, x20    
    adcs    x16, xzr, x16
    adc     x17, xzr, x17  

    // a[4-5] x 2xp377p1_nz --> result: x4:x8
    MUL128x192_COMBA_CUT x2, x3, x19, x20, x21, x4, x5, x6, x7, x8, x22, x23, x24  

    orr     x9, xzr, x8, lsr #1
    lsl     x8, x8, #63
    orr     x8, x8, x7, lsr #1
    lsl     x7, x7, #63
    orr     x7, x7, x6, lsr #1
    lsl     x6, x6, #63  
    orr     x6, x6, x5, lsr #1
    lsl     x5, x5, #63  
    orr     x5, x5, x4, lsr #1
    lsl     x4, x4, #63 
    
    ldp     x19, x20, [sp] 
    adds    x12, x4, x12          // a[4-5]
    adcs    x13, x5, x13 
    ldp     x21, x22, [sp, #16]  
    stp     x12, x13, [x1,#0]     // Final result 
    adcs    x14, x6, x14
    adcs    x15, x7, x15 
    ldp     x23, x24, [sp, #32]
    stp     x14, x15, [x1,#16] 
    adcs    x16, x8, x16 
    adc     x17, x9, x17
    stp     x16, x17, [x1,#32]	
    add     sp, sp, #48
    ret


//***********************************************************************
//  377-bit multiprecision addition
//  Operation: c [x2] = a [x0] + b [x1]
//*********************************************************************** 
.global mp_add377_asm
mp_add377_asm:
    ldp     x3, x4,   [x0,#0]
    ldp     x11, x12, [x1,#0]
    ldp     x5, x6,   [x0,#16]
    ldp     x13, x14, [x1,#16]
    ldp     x7, x8,   [x0,#32]
    ldp     x15, x16, [x1,#32]
    adds    x3, x3, x11
    adcs    x4, x4, x12
    stp     x3, x4,   [x2,#0]
    adcs    x5, x5, x13
    adcs    x6, x6, x14
    stp     x5, x6,   [x2,#16]
    adcs    x7, x7, x15
    adc     x8, x8, x16
    stp     x7, x8,   [x2,#32]
    ret    


//***********************************************************************
//  2x377-bit multiprecision addition
//  Operation: c [x2] = a [x0] + b [x1]
//*********************************************************************** 
.global mp_add377x2_asm
mp_add377x2_asm:
    ldp     x3, x4,   [x0,#0]
    ldp     x11, x12, [x1,#0]
    ldp     x5, x6,   [x0,#16]
    ldp     x13, x14, [x1,#16]

    ldp     x7, x8,   [x0,#32]
    adds    x3, x3, x11
    adcs    x4, x4, x12
    stp     x3, x4,   [x2,#0]
    ldp     x11, x12, [x1,#32]
    adcs    x5, x5, x13
    adcs    x6, x6, x14
    stp     x5, x6,   [x2,#16]
    adcs    x7, x7, x11
    adcs    x8, x8, x12
    stp     x7, x8,   [x2,#32]
    
    ldp     x3, x4,   [x0,#48]
    ldp     x11, x12, [x1,#48]
    ldp     x5, x6,   [x0,#64]
    ldp     x13, x14, [x1,#64]
	
    ldp     x7, x8,   [x0,#80]
    ldp     x15, x16, [x1,#80]
    adcs    x3, x3, x11
    adcs    x4, x4, x12
    stp     x3, x4,   [x2,#48]
    adcs    x5, x5, x13
    adcs    x6, x6, x14
    stp     x5, x6,   [x2,#64]
    adcs    x7, x7, x15
    adc     x8, x8, x16
    stp     x7, x8,   [x2,#80]
    ret


//***********************************************************************
//  2x377-bit multiprecision subtraction/addition
//  Operation: c [x2] = a [x0] - b [x1]. If c < 0, add p377*2^384
//*********************************************************************** 
.global mp_subadd377x2_asm
mp_subadd377x2_asm:
    ldp     x3, x4,   [x0,#0]
    ldp     x11, x12, [x1,#0]
    ldp     x5, x6,   [x0,#16]
    ldp     x13, x14, [x1,#16]
	
    ldp     x7, x8,   [x0,#32]
    subs    x3, x3, x11
    sbcs    x4, x4, x12
    stp     x3, x4,   [x2,#0]
    ldp     x11, x12, [x1,#32]
    sbcs    x5, x5, x13
    sbcs    x6, x6, x14
    stp     x5, x6,   [x2,#16]
    sbcs    x7, x7, x11
    sbcs    x8, x8, x12
    stp     x7, x8,   [x2,#32]
    
    ldp     x3, x4,   [x0,#48]
    ldp     x11, x12, [x1,#48]
    ldp     x5, x6,   [x0,#64]
    ldp     x13, x14, [x1,#64]
	
    ldp     x7, x8,   [x0,#80]
    ldp     x15, x16, [x1,#80]
    sbcs    x3, x3, x11
    sbcs    x4, x4, x12
    ldr     x11, p377
    sbcs    x5, x5, x13
    sbcs    x6, x6, x14
    ldr     x12, p377 + 8
    sbcs    x7, x7, x15
    ldr     x13, p377 + 16
    sbcs    x8, x8, x16
    ldr     x14, p377 + 24
    sbc     x0, xzr, xzr
    ldr     x15, p377 + 32

    // Add p377 anded with the mask in x0
    and     x11, x11, x0 
    and     x12, x12, x0 
    and     x13, x13, x0 
    and     x14, x14, x0
    and     x15, x15, x0
	adds    x3, x3, x11    
	adcs    x4, x4, x11  
    stp     x3, x4,   [x2,#48] 
	adcs    x5, x5, x12   
	adcs    x6, x6, x13  
    stp     x5, x6,   [x2,#64] 
	adcs    x7, x7, x14   
	adc     x8, x8, x15 	
    stp     x7, x8,   [x2,#80]
    ret


//***********************************************************************
//  Double 2x377-bit multiprecision subtraction
//  Operation: c [x2] = c [x2] - a [x0] - b [x1]
//*********************************************************************** 
.global mp_dblsub377x2_asm
mp_dblsub377x2_asm:
    sub     sp, sp, #32
    stp     x19, x20, [sp,#0]
    ldp     x3, x4,   [x2,#0]
    ldp     x5, x6,   [x2,#16]	
    ldp     x15, x16, [x0,#0]
    ldp     x19, x20, [x0,#16]
    ldp     x7, x8,   [x2,#32]
    ldp     x9, x10,  [x2,#48]
    subs    x3, x3, x15
    sbcs    x4, x4, x16
    sbcs    x5, x5, x19
    sbcs    x6, x6, x20
    ldp     x15, x16, [x0,#32]
    ldp     x19, x20, [x0,#48]
    ldp     x11, x12, [x2,#64]
    ldp     x13, x14, [x2,#80]
    sbcs    x7, x7, x15
    sbcs    x8, x8, x16
    ldp     x15, x16, [x0,#64]
    sbcs    x9, x9, x19
    sbcs    x10, x10, x20
    ldp     x19, x20, [x0,#80]
    sbcs    x11, x11, x15
    sbcs    x12, x12, x16
    sbcs    x13, x13, x19
    sbc     x14, x14, x20
	    
    ldp     x15, x16, [x1,#0]
    ldp     x19, x20, [x1,#16]
    subs    x3, x3, x15
    sbcs    x4, x4, x16
    stp     x3, x4,   [x2,#0] 
    sbcs    x5, x5, x19
    sbcs    x6, x6, x20
    ldp     x15, x16, [x1,#32]
    ldp     x19, x20, [x1,#48]
    stp     x5, x6,   [x2,#16]
    sbcs    x7, x7, x15
    sbcs    x8, x8, x16
    ldp     x15, x16, [x1,#64]
    stp     x7, x8,   [x2,#32]
    sbcs    x9, x9, x19
    sbcs    x10, x10, x20
    ldp     x19, x20, [x1,#80]
    stp     x9, x10,  [x2,#48]
    sbcs    x11, x11, x15
    sbcs    x12, x12, x16
    sbcs    x13, x13, x19
    sbc     x14, x14, x20
    stp     x11, x12, [x2,#64]
    stp     x13, x14, [x2,#80]
	  
    ldp     x19, x20, [sp, #0]
    add     sp, sp, #32
    ret