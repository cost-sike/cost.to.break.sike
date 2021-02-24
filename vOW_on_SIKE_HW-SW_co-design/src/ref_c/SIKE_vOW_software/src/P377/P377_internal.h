/********************************************************************************************
* Internal header file for P377
*********************************************************************************************/  

#ifndef P377_INTERNAL_H
#define P377_INTERNAL_H

#include "../config.h"
 

#if (TARGET == TARGET_AMD64) || (TARGET == TARGET_ARM64)
    #define NWORDS_FIELD    6               // Number of words of a 377-bit field element
    #define p377_ZERO_WORDS 2               // Number of "0" digits in the least significant part of p377 + 1     
#elif (TARGET == TARGET_x86)
    #define NWORDS_FIELD    12 
    #define p377_ZERO_WORDS 5
#endif
    

// Basic constants

#define NBITS_FIELD             377  
#define MAXBITS_FIELD           384                
#define MAXWORDS_FIELD          ((MAXBITS_FIELD+RADIX-1)/RADIX)     // Max. number of words to represent field elements
#define NWORDS64_FIELD          ((NBITS_FIELD+63)/64)               // Number of 64-bit words of a 377-bit field element 
#define NBITS_ORDER             192
#define NWORDS_ORDER            ((NBITS_ORDER+RADIX-1)/RADIX)       // Number of words of oA and oB, where oA and oB are the subgroup orders of Alice and Bob, resp.
#define NWORDS64_ORDER          ((NBITS_ORDER+63)/64)               // Number of 64-bit words of a 192-bit element 
#define MAXBITS_ORDER           NBITS_ORDER                         
#define ALICE                   0
#define BOB                     1 
#define OALICE_BITS             191  
#define OBOB_BITS               186     
#define OBOB_EXPON              117    
#define MASK_ALICE              0x7F
#define MASK_BOB                0x01 
#define PRIME                   p377 
#define PARAM_A                 6  
#define PARAM_C                 1
// Fixed parameters for isogeny tree computation
#define MAX_INT_POINTS_ALICE    7                 ////////////////// NOTE: TO BE UPDATED
#define MAX_INT_POINTS_BOB      8      
#define MAX_Alice               95
#define MAX_Bob                 117
#define MSG_BYTES               16
#define SECRETKEY_A_BYTES       ((OALICE_BITS + 7) / 8)
#define SECRETKEY_B_BYTES       ((OBOB_BITS - 1 + 7) / 8)
#define FP2_ENCODED_BYTES       2*((NBITS_FIELD + 7) / 8)


// SIDH's basic element definitions and point representations

typedef digit_t felm_t[NWORDS_FIELD];                                 // Datatype for representing 377-bit field elements (384-bit max.)
typedef digit_t dfelm_t[2*NWORDS_FIELD];                              // Datatype for representing double-precision 2x377-bit field elements (2x384-bit max.) 
typedef felm_t  f2elm_t[2];                                           // Datatype for representing quadratic extension field elements GF(p377^2)
        
typedef struct { f2elm_t X; f2elm_t Z; } point_proj;                  // Point representation in projective XZ Montgomery coordinates.
typedef point_proj point_proj_t[1];



/**************** Function prototypes ****************/
/************* Multiprecision functions **************/ 

// Copy wordsize digits, c = a, where lng(a) = nwords
void copy_words(const digit_t* a, digit_t* c, const unsigned int nwords);

// Multiprecision addition, c = a+b, where lng(a) = lng(b) = nwords. Returns the carry bit 
unsigned int mp_add(const digit_t* a, const digit_t* b, digit_t* c, const unsigned int nwords);

// 377-bit multiprecision addition, c = a+b
void mp_add377(const digit_t* a, const digit_t* b, digit_t* c);
void mp_add377_asm(const digit_t* a, const digit_t* b, digit_t* c); 

// Multiprecision subtraction, c = a-b, where lng(a) = lng(b) = nwords. Returns the borrow bit 
unsigned int mp_sub(const digit_t* a, const digit_t* b, digit_t* c, const unsigned int nwords);

// 377-bit multiprecision subtraction, c = a-b+2p or c = a-b+4p
extern void mp_sub377_p2(const digit_t* a, const digit_t* b, digit_t* c);
extern void mp_sub377_p4(const digit_t* a, const digit_t* b, digit_t* c);
void mp_sub377_p2_asm(const digit_t* a, const digit_t* b, digit_t* c);
void mp_sub377_p4_asm(const digit_t* a, const digit_t* b, digit_t* c); 

// 2x377-bit multiprecision subtraction followed by addition with p377*2^384, c = a-b+(p377*2^384) if a-b < 0, otherwise c=a-b 
void mp_subaddx2_asm(const digit_t* a, const digit_t* b, digit_t* c);
void mp_subadd377x2_asm(const digit_t* a, const digit_t* b, digit_t* c);

// Double 2x377-bit multiprecision subtraction, c = c-a-b, where c > a and c > b
void mp_dblsub377x2_asm(const digit_t* a, const digit_t* b, digit_t* c);

// Multiprecision left shift
void mp_shiftleft(digit_t* x, unsigned int shift, const unsigned int nwords);

// Multiprecision right shift by one
void mp_shiftr1(digit_t* x, const unsigned int nwords);

// Multiprecision left right shift by one    
void mp_shiftl1(digit_t* x, const unsigned int nwords);

// Digit multiplication, digit * digit -> 2-digit result
void digit_x_digit(const digit_t a, const digit_t b, digit_t* c); 

// Multiprecision comba multiply, c = a*b, where lng(a) = lng(b) = nwords.
void mp_mul(const digit_t* a, const digit_t* b, digit_t* c, const unsigned int nwords);

/************ Field arithmetic functions *************/

// Copy of a field element, c = a
void fpcopy377(const digit_t* a, digit_t* c);

// Zeroing a field element, a = 0
void fpzero377(digit_t* a);

// Non constant-time comparison of two field elements. If a = b return TRUE, otherwise, return FALSE
bool fpequal377_non_constant_time(const digit_t* a, const digit_t* b); 

// Modular addition, c = a+b mod p377
extern void fpadd377(const digit_t* a, const digit_t* b, digit_t* c);
extern void fpadd377_asm(const digit_t* a, const digit_t* b, digit_t* c);

// Modular subtraction, c = a-b mod p377
extern void fpsub377(const digit_t* a, const digit_t* b, digit_t* c);
extern void fpsub377_asm(const digit_t* a, const digit_t* b, digit_t* c);

// Modular negation, a = -a mod p377        
extern void fpneg377(digit_t* a);  

// Modular division by two, c = a/2 mod p377.
void fpdiv2_377(const digit_t* a, digit_t* c);

// Modular correction to reduce field element a in [0, 2*p377-1] to [0, p377-1].
void fpcorrection377(digit_t* a);

// 377-bit Montgomery reduction, c = a mod p
void rdc_mont(digit_t* a, digit_t* c);
void rdc377_asm(digit_t* ma, digit_t* mc);
            
// Field multiplication using Montgomery arithmetic, c = a*b*R^-1 mod p377, where R=2^768
void fpmul377_mont(const digit_t* a, const digit_t* b, digit_t* c);
void mul377_asm(const digit_t* a, const digit_t* b, digit_t* c);
   
// Field squaring using Montgomery arithmetic, c = a*b*R^-1 mod p377, where R=2^768
void fpsqr377_mont(const digit_t* ma, digit_t* mc);

// Conversion to Montgomery representation
void to_mont(const digit_t* a, digit_t* mc);
    
// Conversion from Montgomery representation to standard representation
void from_mont(const digit_t* ma, digit_t* c);

// Field inversion, a = a^-1 in GF(p377)
void fpinv377_mont(digit_t* a);

// Field inversion, a = a^-1 in GF(p377) using the binary GCD 
void fpinv377_mont_bingcd(digit_t* a);

// Chain to compute (p377-3)/4 using Montgomery arithmetic
void fpinv377_chain_mont(digit_t* a);

/************ GF(p^2) arithmetic functions *************/

// Conversion of GF(p^2) element from Montgomery to standard representation, and encoding by removing leading 0 bytes
void fp2_encode(const f2elm_t x, unsigned char *enc);

// Parse byte sequence back into GF(p^2) element, and conversion to Montgomery representation
void fp2_decode(const unsigned char *enc, f2elm_t x);

// Is a = b? return 1 (TRUE) if condition is true, 0 (FALSE) otherwise.
bool fp2_is_equal(const f2elm_t a, const f2elm_t b);
    
// Copy of a GF(p377^2) element, c = a
void fp2copy377(const f2elm_t a, f2elm_t c);

// Zeroing a GF(p377^2) element, a = 0
void fp2zero377(f2elm_t a);

// GF(p377^2) negation, a = -a in GF(p377^2)
void fp2neg377(f2elm_t a);

// GF(p377^2) addition, c = a+b in GF(p377^2)
extern void fp2add377(const f2elm_t a, const f2elm_t b, f2elm_t c);           

// GF(p377^2) subtraction, c = a-b in GF(p377^2)
extern void fp2sub377(const f2elm_t a, const f2elm_t b, f2elm_t c); 

// GF(p377^2) division by two, c = a/2  in GF(p377^2) 
void fp2div2_377(const f2elm_t a, f2elm_t c);

// Modular correction, a = a in GF(p377^2)
void fp2correction377(f2elm_t a);
            
// GF(p377^2) squaring using Montgomery arithmetic, c = a^2 in GF(p377^2)
void fp2sqr377_mont(const f2elm_t a, f2elm_t c);
 
// GF(p377^2) multiplication using Montgomery arithmetic, c = a*b in GF(p377^2)
void fp2mul377_mont(const f2elm_t a, const f2elm_t b, f2elm_t c);
    
// Conversion of a GF(p377^2) element to Montgomery representation
void to_fp2mont(const f2elm_t a, f2elm_t mc);

// Conversion of a GF(p377^2) element from Montgomery representation to standard representation
void from_fp2mont(const f2elm_t ma, f2elm_t c);

// GF(p377^2) inversion using Montgomery arithmetic, a = (a0-i*a1)/(a0^2+a1^2)
void fp2inv377_mont(f2elm_t a);

// GF(p377^2) inversion, a = (a0-i*a1)/(a0^2+a1^2), GF(p377) inversion done using the binary GCD 
void fp2inv377_mont_bingcd(f2elm_t a);

// n-way Montgomery inversion
void mont_n_way_inv(const f2elm_t* vec, const int n, f2elm_t* out);

/************ Elliptic curve and isogeny functions *************/

// Computes the j-invariant of a Montgomery curve with projective constant.
void j_inv(const f2elm_t A, const f2elm_t C, f2elm_t jinv);

// Simultaneous doubling and differential addition.
void xDBLADD(point_proj_t P, point_proj_t Q, const f2elm_t xPQ, const f2elm_t A24);

// Doubling of a Montgomery point in projective coordinates (X:Z).
void xDBL(const point_proj_t P, point_proj_t Q, const f2elm_t A24plus, const f2elm_t C24);

// Computes [2^e](X:Z) on Montgomery curve with projective constant via e repeated doublings.
void xDBLe(const point_proj_t P, point_proj_t Q, const f2elm_t A24plus, const f2elm_t C24, const int e);

// Differential addition.
void xADD(point_proj_t P, const point_proj_t Q, const f2elm_t xPQ);

// Computes the corresponding 4-isogeny of a projective Montgomery point (X4:Z4) of order 4.
void get_4_isog(const point_proj_t P, f2elm_t A24plus, f2elm_t C24, f2elm_t* coeff);

// Evaluates the isogeny at the point (X:Z) in the domain of the isogeny.
void eval_4_isog(point_proj_t P, f2elm_t* coeff);

// Tripling of a Montgomery point in projective coordinates (X:Z).
void xTPL(const point_proj_t P, point_proj_t Q, const f2elm_t A24minus, const f2elm_t A24plus);

// Computes [3^e](X:Z) on Montgomery curve with projective constant via e repeated triplings.
void xTPLe(const point_proj_t P, point_proj_t Q, const f2elm_t A24minus, const f2elm_t A24plus, const int e);

// Computes the corresponding 3-isogeny of a projective Montgomery point (X3:Z3) of order 3.
void get_3_isog(const point_proj_t P, f2elm_t A24minus, f2elm_t A24plus, f2elm_t* coeff);

// Computes the 3-isogeny R=phi(X:Z), given projective point (X3:Z3) of order 3 on a Montgomery curve and a point P with coefficients given in coeff.
void eval_3_isog(point_proj_t Q, const f2elm_t* coeff);

// 3-way simultaneous inversion
void inv_3_way(f2elm_t z1, f2elm_t z2, f2elm_t z3);

// Given the x-coordinates of P, Q, and R, returns the value A corresponding to the Montgomery curve E_A: y^2=x^3+A*x^2+x such that R=Q-P on E_A.
void get_A(const f2elm_t xP, const f2elm_t xQ, const f2elm_t xR, f2elm_t A);

// Isogeny tree traversal
void TraverseTree(f2elm_t jinv, point_proj_t R, f2elm_t A24plus, f2elm_t C24, const unsigned int *strat, unsigned int lenstrat, bool keygen, point_proj_t PhiP, point_proj_t PhiQ, point_proj_t PhiR);


#endif
