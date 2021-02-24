/********************************************************************************************
* SIDH: an efficient supersingular isogeny cryptography library
*
* Abstract: modular arithmetic optimized for 64-bit ARMv8 platforms for P377
*********************************************************************************************/

#include "../P377_internal.h"

// Global constants
extern const uint64_t p377[NWORDS_FIELD]; 
extern const uint64_t p377x2[NWORDS_FIELD]; 


__inline void mp_sub377_p2(const digit_t* a, const digit_t* b, digit_t* c)
{ // Multiprecision subtraction with correction with 2*p, c = a-b+2p. 
    
    mp_sub377_p2_asm(a, b, c); 
} 


__inline void mp_sub377_p4(const digit_t* a, const digit_t* b, digit_t* c)
{ // Multiprecision subtraction with correction with 4*p, c = a-b+4p. 
    
    mp_sub377_p4_asm(a, b, c);
}


__inline void fpadd377(const digit_t* a, const digit_t* b, digit_t* c)
{ // Modular addition, c = a+b mod p377.
  // Inputs: a, b in [0, 2*p377-1] 
  // Output: c in [0, 2*p377-1]

    fpadd377_asm(a, b, c);
} 


__inline void fpsub377(const digit_t* a, const digit_t* b, digit_t* c)
{ // Modular subtraction, c = a-b mod p377.
  // Inputs: a, b in [0, 2*p377-1] 
  // Output: c in [0, 2*p377-1] 

    fpsub377_asm(a, b, c);
}


__inline void fpneg377(digit_t* a)
{ // Modular negation, a = -a mod p377.
  // Input/output: a in [0, 2*p377-1] 
    unsigned int i, borrow = 0;

    for (i = 0; i < NWORDS_FIELD; i++) {
        SUBC(borrow, ((digit_t*)p377x2)[i], a[i], borrow, a[i]); 
    }
}


void fpdiv2_377(const digit_t* a, digit_t* c)
{ // Modular division by two, c = a/2 mod p377.
  // Input : a in [0, 2*p377-1] 
  // Output: c in [0, 2*p377-1] 
    unsigned int i, carry = 0;
    digit_t mask;
        
    mask = 0 - (digit_t)(a[0] & 1);    // If a is odd compute a+p377
    for (i = 0; i < NWORDS_FIELD; i++) {
        ADDC(carry, a[i], ((digit_t*)p377)[i] & mask, carry, c[i]); 
    }

    mp_shiftr1(c, NWORDS_FIELD);
} 


void fpcorrection377(digit_t* a)
{ // Modular correction to reduce field element a in [0, 2*p377-1] to [0, p377-1].
    unsigned int i, borrow = 0;
    digit_t mask;

    for (i = 0; i < NWORDS_FIELD; i++) {
        SUBC(borrow, a[i], ((digit_t*)p377)[i], borrow, a[i]);
    }
    mask = 0 - (digit_t)borrow;

    borrow = 0;
    for (i = 0; i < NWORDS_FIELD; i++) {
        ADDC(borrow, a[i], ((digit_t*)p377)[i] & mask, borrow, a[i]);
    }
}


void mp_mul(const digit_t* a, const digit_t* b, digit_t* c, const unsigned int nwords)
{ // Multiprecision multiply, c = a*b, where lng(a) = lng(b) = nwords.

    (void)nwords;
    mul377_asm(a, b, c);
}



void rdc_mont(digit_t* ma, digit_t* mc)
{ // Montgomery reduction exploiting special form of the prime.
  // mc = ma*R^-1 mod p377x2, where R = 2^384.
  // If ma < 2^384*p377, the output mc is in the range [0, 2*p377-1].
  // ma is assumed to be in Montgomery representation.
  
    rdc377_asm(ma, mc);
}
