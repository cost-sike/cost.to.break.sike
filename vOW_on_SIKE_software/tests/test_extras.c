/********************************************************************************************
* SIDH: an efficient supersingular isogeny cryptography library
*
* Abstract: utility functions for testing and benchmarking
*********************************************************************************************/

#include "test_extras.h"
#if (OS_TARGET == OS_WIN)
    #include <intrin.h>
    #include <windows.h>
#elif (OS_TARGET == OS_LINUX)
    #if (TARGET == TARGET_ARM64)
        #include <time.h>
    #endif
    #include <unistd.h>
#endif
#include <stdlib.h>     

#ifdef p_32_20           /* p128 = 2^32*3^20*23 - 1 */
    static uint64_t p128[2] = { 0xAC0E7A06FFFFFFFF, 0x0000000000000012 };
    #define NBITS_FIELD128     69
#elif defined p_36_22    /* p128 = 2^36*3^22*31 - 1 */
    static uint64_t p128[2] = { 0x02A0B06FFFFFFFFF, 0x0000000000000E28 };
    #define NBITS_FIELD128     76
#else
    static uint64_t p128[2] = { 0, 0 };
    #define NBITS_FIELD128    0
#endif
    
static uint64_t p377[6]  = { 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0x7FFFFFFFFFFFFFFF, 0x0B46D546BC2A5699, 0xA879CC6988CE7CF5, 0x015B702E0C542196 };
static uint64_t p434[7]  = { 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFDC1767AE2FFFFFF, 
                             0x7BC65C783158AEA3, 0x6CFC5FD681C52056, 0x0002341F27177344 };

#define NBITS_FIELD377    377
#define NBITS_FIELD434    434


int64_t cpucycles(void)
{ // Access system counter for benchmarking
#if (OS_TARGET == OS_WIN) && (TARGET == TARGET_AMD64 || TARGET == TARGET_x86)
    return __rdtsc();
#elif (OS_TARGET == OS_LINUX) && (TARGET == TARGET_AMD64 || TARGET == TARGET_x86)
    unsigned int hi, lo;

    __asm volatile ("rdtsc\n\t" : "=a" (lo), "=d"(hi));
    return ((int64_t)lo) | (((int64_t)hi) << 32);
#elif (OS_TARGET == OS_LINUX) && (TARGET == TARGET_ARM64)
    struct timespec time;

    clock_gettime(CLOCK_REALTIME, &time);
    return (int64_t)(time.tv_sec*1e9 + time.tv_nsec);
#else
    return 0;            
#endif
}


int compare_words(digit_t* a, digit_t* b, unsigned int nwords)
{ // Comparing "nword" elements, a=b? : (1) a>b, (0) a=b, (-1) a<b
  // SECURITY NOTE: this function does not have constant-time execution. TO BE USED FOR TESTING ONLY.
    int i;

    for (i = nwords-1; i >= 0; i--)
    {
        if (a[i] > b[i]) return 1;
        else if (a[i] < b[i]) return -1;
    }

    return 0; 
}


static void sub_test(digit_t* a, digit_t* b, digit_t* c, unsigned int nwords)
{ // Subtraction without borrow, c = a-b where a>b
  // SECURITY NOTE: this function does not have constant-time execution. It is for TESTING ONLY.     
    unsigned int i;
    digit_t res, carry, borrow = 0;
  
    for (i = 0; i < nwords; i++)
    {
        res = a[i] - b[i];
        carry = (a[i] < b[i]);
        c[i] = res - borrow;
        borrow = carry || (res < borrow);
    } 
}


void fprandom128_test(digit_t* a)
{ // Generating a pseudo-random field element in [0, p128-1] 
  // SECURITY NOTE: distribution is not fully uniform. TO BE USED FOR TESTING ONLY.
    unsigned int i, diff = 128-NBITS_FIELD128, nwords = NBITS_TO_NWORDS(NBITS_FIELD128);                    
    unsigned char* string = NULL;

    for (i = 0; i < NBITS_TO_NWORDS(128); i++) a[i] = 0;

    string = (unsigned char*)a;
    for (i = 0; i < sizeof(digit_t)*nwords; i++) {
        *(string + i) = (unsigned char)rand();              // Obtain 128-bit number
    }
    a[nwords-1] &= (((digit_t)(-1) << diff) >> diff);

    while (compare_words((digit_t*)p128, a, nwords) < 1) {  // Force it to [0, modulus-1]
        sub_test(a, (digit_t*)p128, a, nwords);
    }
}


void fprandom377_test(digit_t* a)
{ // Generating a pseudo-random field element in [0, p377-1] 
  // SECURITY NOTE: distribution is not fully uniform. TO BE USED FOR TESTING ONLY.
    unsigned int i, diff = 384-NBITS_FIELD377, nwords = NBITS_TO_NWORDS(NBITS_FIELD377);
    unsigned char* string = NULL;

    string = (unsigned char*)a;
    for (i = 0; i < sizeof(digit_t)*nwords; i++) {
        *(string + i) = (unsigned char)rand();              // Obtain 384-bit number
    }
    a[nwords-1] &= (((digit_t)(-1) << diff) >> diff);

    while (compare_words((digit_t*)p377, a, nwords) < 1) {  // Force it to [0, modulus-1]
        sub_test(a, (digit_t*)p377, a, nwords);
    }
}


void fprandom434_test(digit_t* a)
{ // Generating a pseudo-random field element in [0, p434-1] 
  // SECURITY NOTE: distribution is not fully uniform. TO BE USED FOR TESTING ONLY.
    unsigned int i, diff = 448-NBITS_FIELD434, nwords = NBITS_TO_NWORDS(NBITS_FIELD434);
    unsigned char* string = NULL;

    string = (unsigned char*)a;
    for (i = 0; i < sizeof(digit_t)*nwords; i++) {
        *(string + i) = (unsigned char)rand();              // Obtain 448-bit number
    }
    a[nwords-1] &= (((digit_t)(-1) << diff) >> diff);

    while (compare_words((digit_t*)p434, a, nwords) < 1) {  // Force it to [0, modulus-1]
        sub_test(a, (digit_t*)p434, a, nwords);
    }
}


void fp2random128_test(digit_t* a)
{ // Generating a pseudo-random element in GF(p128^2) 
  // SECURITY NOTE: distribution is not fully uniform. TO BE USED FOR TESTING ONLY.

    fprandom128_test(a);
    fprandom128_test(a+NBITS_TO_NWORDS(128));
}


void fp2random377_test(digit_t* a)
{ // Generating a pseudo-random element in GF(p377^2) 
  // SECURITY NOTE: distribution is not fully uniform. TO BE USED FOR TESTING ONLY.

    fprandom377_test(a);
    fprandom377_test(a+NBITS_TO_NWORDS(NBITS_FIELD377));
}


void fp2random434_test(digit_t* a)
{ // Generating a pseudo-random element in GF(p434^2) 
  // SECURITY NOTE: distribution is not fully uniform. TO BE USED FOR TESTING ONLY.

    fprandom434_test(a);
    fprandom434_test(a+NBITS_TO_NWORDS(NBITS_FIELD434));
}


void sleep_ms(digit_t ms)
{
 #if (OS_TARGET == OS_WIN)
    Sleep((DWORD)ms);
#elif (OS_TARGET == OS_LINUX)
    usleep(ms*1000);
#endif
}