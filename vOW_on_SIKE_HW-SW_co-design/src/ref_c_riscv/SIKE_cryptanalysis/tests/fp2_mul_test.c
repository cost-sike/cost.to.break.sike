// software test for F(P^2) multiplication

#include "../../../ref_c/SIKE_vOW_software_USENIX/src/config.h"
#include "../../../ref_c/SIKE_vOW_software_USENIX/src/P128/P128_internal.h" 
#include "test_extras.h"
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h> 

#ifndef x86
#include <Murax.h>
#endif

void main() {

  f2elm_t a, b, c, ma, mb, mc;

  digit_t *sub_res = (digit_t*)&(mc[0]);
  digit_t *add_res = (digit_t*)&(mc[1]);

  digit_t *a_0 = (digit_t*)&(ma[0]);
  digit_t *a_1 = (digit_t*)&(ma[1]);

  digit_t *b_0 = (digit_t*)&(mb[0]);
  digit_t *b_1 = (digit_t*)&(mb[1]); 

  /* Intializes random number generator */
  // #ifdef x86
  // time_t t;
  // srand((unsigned) time(&t));
  // #endif
  
  // generate random inputs from F(p^2)
  fp2random128_test((digit_t*)ma);
  fp2random128_test((digit_t*)ma); 
  fp2random128_test((digit_t*)mb); 
   
  // convert a and b to Montgomery format
  // to_fp2mont(a, ma); 
  // to_fp2mont(b, mb);

  // fprandom128_test(a_0);
  // fprandom128_test(b_0);

  // for (int i=0; i<NWORDS_FIELD; i++) {
  //   a_1[i] = 0;
  //   b_1[i] = 0;
  // }

  printf("\n");
  
  #ifdef x86
  FILE * fp_a_0;
  FILE * fp_a_1;
  FILE * fp_b_0;
  FILE * fp_b_1;

  fp_a_0 = fopen ("mem_0_a_0.txt", "w+");
  fp_a_1 = fopen ("mem_0_a_1.txt", "w+");
  fp_b_0 = fopen ("mem_0_b_0.txt", "w+");
  fp_b_1 = fopen ("mem_0_b_1.txt", "w+");

  for (int i=0; i<NWORDS_FIELD; i++) {
    fprintf(fp_a_0, "%08x\n", a_0[i]);
    fprintf(fp_a_1, "%08x\n", a_1[i]);
    fprintf(fp_b_0, "%08x\n", b_0[i]);
    fprintf(fp_b_1, "%08x\n", b_1[i]);
  }

  fclose(fp_a_0);
  fclose(fp_a_1);
  fclose(fp_b_0);
  fclose(fp_b_1);
  #endif


  for (int i=0; i<NWORDS_FIELD; i++) {
    printf("%08x\n", a_0[i]); 
  }

  printf("\n");
   
  for (int i=0; i<NWORDS_FIELD; i++) {
    printf("%08x\n", a_1[i]); 
  }

  printf("\n");

  for (int i=0; i<NWORDS_FIELD; i++) {
    printf("%08x\n", b_0[i]); 
  }

  printf("\n");
 
  for (int i=0; i<NWORDS_FIELD; i++) {
    printf("%08x\n", b_1[i]); 
  }


  printf("\n");
 
  uint64_t t0 = -cpucycles();
  
  // Montgomery multiplication on F(p^2)
  fp2mul128_mont(ma, mb, mc);
  // fp2mul128_mont(ma[0], mb[0], mc[0]);

  t0 += cpucycles();

  // modular correction to reduce c1 in [0, 2*p128-1] to [0, p128-1]
  fpcorrection128(sub_res);
  fpcorrection128(add_res);

  // unsigned int borrow = 0;
  // for (int i = 0; i < NWORDS_FIELD; i++) {
  //   ADDC(borrow, add_res[i], ((digit_t*)p128)[i], borrow, add_res[i]); 
  // }

  // for (int i=0; i<NWORDS_FIELD; i++) {
  //   printf("%d    ", i); 
  //   printf("%" PRIu32, sub_res[i]);
  //   printf("\n");
  // }

  printf("\n");
  
  #ifdef x86
  FILE * fp_sub_res;
  FILE * fp_add_res;
  
  fp_sub_res = fopen ("mult_sub_res_C.txt", "w+");
  fp_add_res = fopen ("mult_add_res_C.txt", "w+");

  for (int i=0; i<NWORDS_FIELD; i++) {
    // printf("%d    ", i); 
    // printf("%" PRIu32, add_res[i]);
    fprintf(fp_sub_res, "%08x\n", sub_res[i]);
    fprintf(fp_add_res, "%08x\n", add_res[i]);
    //fprintf(fp_add_res, "%08x\n", (digit_t*)&mc[i]);
    // printf("\n");
  }
  
  fclose(fp_sub_res);
  fclose(fp_add_res);
  #endif
   
  printf("\nresult for sub part:\n");

  for (int i=0; i<NWORDS_FIELD; i++) {
    printf("%d    ", i); 
    printf("%08x\n", sub_res[i]); 
  }

  printf("\nresult for add part:\n");

  for (int i=0; i<NWORDS_FIELD; i++) {
    printf("%d    ", i); 
    printf("%08x\n", add_res[i]); 
  } 
  // printf("\nsoftware test for F(P^2) multiplication finishes.\n");

  printf("\n------------PERFORMANCE------------\n\n");
  printf("cycles for fp2mul128_mont in sw: %" PRIu64 "\n\n", t0);

}
