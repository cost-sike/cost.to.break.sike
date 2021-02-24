/********************************************************************************************
* Supersingular isogeny parameters and generation of functions for P128
*********************************************************************************************/  

#include "P128_internal.h"


// Encoding of field elements, elements over Z_order, elements over GF(p^2) and elliptic curve points:
// --------------------------------------------------------------------------------------------------
// Elements over GF(p) and Z_order are encoded with the least significant octet (and digit) located at the leftmost position (i.e., little endian format). 
// Elements (a+b*i) over GF(p^2), where a and b are defined over GF(p), are encoded as {a, b}, with a in the least significant position.
// Elliptic curve points P = (x,y) are encoded as {x, y}, with x in the least significant position. 
// Internally, the number of digits used to represent all these elements is obtained by approximating the number of bits to the immediately greater multiple of 32.
// For example, a 128-bit field element is represented with Ceil(128 / 64) = 8 64-bit digits or Ceil(128 / 32) = 16 32-bit digits.

//
// Curve isogeny system "SIDHp128". Base curve: Montgomery curve By^2 = Cx^3 + Ax^2 + Cx defined over GF(p128^2), where A=6, B=1, C=1
//

/*
 * p128p1 = p128 + 1
 * p128x2 = 2*p128
 * Montgomery_rprime = -(p128)^-1 mod 2^128
 * Montgomery_R2 = (2^128)^2 mod p128
 * Montgomery_one = 2^128 mod p128
 */

#ifdef p_32_20
    /* p128 = 2^32*3^20*23 - 1 */
    const uint64_t p128[NWORDS64_FIELD] = { 0xAC0E7A06FFFFFFFF, 0x12 };
    const uint64_t p128p1[NWORDS64_FIELD] = { 0xAC0E7A0700000000, 0x12 };
    const uint64_t p128x2[NWORDS64_FIELD] = { 0x581CF40DFFFFFFFE, 0x25 };
    const uint64_t p128x4[NWORDS64_FIELD] = { 0xB039E81BFFFFFFFC, 0x4A };
    const uint64_t p128pp[NWORDS64_FIELD] = { 0xAC0E7A0700000001, 0x96F0AD1DFAEEAC43 };
    const uint64_t Montgomery_rprime1[NWORDS64_ORDER] = { 0xAC0E7A0700000001, 0x96F0AD1DFAEEAC43 };
    const uint64_t Montgomery_R2[NWORDS64_ORDER] = { 0x835010E3A34C2C1C, 0x3 };
    const uint64_t Montgomery_one[NWORDS64_ORDER] = { 0xD9FEFBEAD8BA0D2B, 0x4 };
#elif defined p_36_22
    /* p128 = 2^36*3^22*31 - 1 */
    const uint64_t p128[NWORDS64_FIELD] = { 0x2A0B06FFFFFFFFF, 0xE28 };
    const uint64_t p128p1[NWORDS64_FIELD] = { 0x2A0B07000000000, 0xE28 };
    const uint64_t p128x2[NWORDS64_FIELD] = { 0x54160DFFFFFFFFE, 0x1C50 };
    const uint64_t p128x4[NWORDS64_FIELD] = { 0xA82C1BFFFFFFFFC, 0x38A0 };
    const uint64_t p128pp[NWORDS64_FIELD] = { 0x02A0B07000000001, 0x7AAFBA9EC59A3F28 };
    const uint64_t Montgomery_rprime1[NWORDS64_ORDER] = { 0x2A0B07000000001, 0x7AAFBA9EC59A3F28 };
    const uint64_t Montgomery_R2[NWORDS64_ORDER] = { 0x9AEB249E616945D3, 0xDDE };
    const uint64_t Montgomery_one[NWORDS64_ORDER] = { 0x68B83F2624F57D33, 0x486 };
#endif

// Setting up macro defines and including GF(p), GF(p^2), curve, isogeny and kex functions
#define fpcopy                        fpcopy128
#define fpzero                        fpzero128
#define fpadd                         fpadd128
#define fpsub                         fpsub128
#define fpneg                         fpneg128
#define fpdiv2                        fpdiv2_128
#define fpcorrection                  fpcorrection128
#define fpmul_mont                    fpmul128_mont
#define fpsqr_mont                    fpsqr128_mont
#define fpinv_mont                    fpinv128_mont
#define fpinv_mont_ct                 fpinv128_mont_ct
#define fpinv_chain_mont              fpinv128_chain_mont
#define fpinv_mont_bingcd             fpinv128_mont_bingcd
#define fp2copy                       fp2copy128
#define fp2zero                       fp2zero128
#define fp2add                        fp2add128
#define fp2sub                        fp2sub128
#define mp_sub_p2                     mp_sub128_p2
#define mp_sub_p4                     mp_sub128_p4
#define sub_p4                        mp_sub_p4
#define fp2neg                        fp2neg128
#define fp2div2                       fp2div2_128
#define fp2correction                 fp2correction128
#define fp2mul_mont                   fp2mul128_mont
#define fp2sqr_mont                   fp2sqr128_mont
#define fp2inv_mont                   fp2inv128_mont
#define fp2inv_mont_ct                fp2inv128_mont_ct
#define fp2inv_mont_bingcd            fp2inv128_mont_bingcd
#define mp_add_asm                    mp_add128_asm
#define mp_subaddx2_asm               mp_subadd128x2_asm
#define mp_dblsubx2_asm               mp_dblsub128x2_asm
#define crypto_kem_keypair            crypto_kem_keypair_SIKEp128
#define crypto_kem_enc                crypto_kem_enc_SIKEp128
#define crypto_kem_dec                crypto_kem_dec_SIKEp128
#define random_mod_order_A            random_mod_order_A_SIDHp128
#define random_mod_order_B            random_mod_order_B_SIDHp128

#include "../fpx.c"
#include "../ec_isogeny.c"