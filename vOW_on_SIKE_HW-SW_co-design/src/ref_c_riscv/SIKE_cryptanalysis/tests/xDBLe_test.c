// software test for xDBLe function

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
  f2elm_t A24, C24;
  point_proj_t P;

  digit_t *A24_0 = (digit_t*)&(A24[0]);
  digit_t *A24_1 = (digit_t*)&(A24[1]);
  digit_t *C24_0 = (digit_t*)&(C24[0]);
  digit_t *C24_1 = (digit_t*)&(C24[1]);
  digit_t *XP_0 = (digit_t*)&((P->X)[0]); 
  digit_t *XP_1 = (digit_t*)&((P->X)[1]);
  digit_t *ZP_0 = (digit_t*)&((P->Z)[0]); 
  digit_t *ZP_1 = (digit_t*)&((P->Z)[1]);

  /* Intializes random number generator */
  // #ifdef x86
  // time_t t;
  // srand((unsigned) time(&t));
  // #endif

  fp2random128_test((digit_t*)A24); 
  fp2random128_test((digit_t*)C24);
  fp2random128_test((digit_t*)(P->X)); 
  fp2random128_test((digit_t*)(P->Z));

  printf("\ninput XP_0:\n");

  for (int i=0; i<NWORDS_FIELD; i++) {
    printf("%d    ", i); 
    printf("%x\n", XP_0[i]); 
  }

  printf("\ninput XP_1:\n");

  for (int i=0; i<NWORDS_FIELD; i++) {
    printf("%d    ", i); 
    printf("%x\n", XP_1[i]);  
  }

  printf("\ninput ZP_0:\n");

  for (int i=0; i<NWORDS_FIELD; i++) {
    printf("%d    ", i); 
    printf("%x\n", ZP_0[i]); 
  }

  printf("\ninput ZP_1:\n");

  for (int i=0; i<NWORDS_FIELD; i++) {
    printf("%d    ", i); 
    printf("%x\n", ZP_1[i]);  
  }

  printf("\ninput A24_0:\n");

  for (int i=0; i<NWORDS_FIELD; i++) {
    printf("%d    ", i); 
    printf("%x\n", A24_0[i]); 
  }

  printf("\ninput A24_1:\n");

  for (int i=0; i<NWORDS_FIELD; i++) {
    printf("%d    ", i); 
    printf("%x\n", A24_1[i]); 
  }

  printf("\ninput C24_0:\n");

  for (int i=0; i<NWORDS_FIELD; i++) {
    printf("%d    ", i); 
    printf("%x\n", C24_0[i]);  
  }

  printf("\ninput C24_1:\n");

  for (int i=0; i<NWORDS_FIELD; i++) {
    printf("%d    ", i); 
    printf("%x\n", C24_1[i]);  
  }
/*
  #ifdef x86
  // write XP, ZP, A24, C24 to files
  FILE * fp_A24_0;
  FILE * fp_A24_1;
  FILE * fp_C24_0;
  FILE * fp_C24_1; 
  FILE * fp_XP_0;
  FILE * fp_XP_1;
  FILE * fp_ZP_0;
  FILE * fp_ZP_1; 

  fp_A24_0 = fopen("mem_A24_0.txt", "w+");
  fp_A24_1 = fopen("mem_A24_1.txt", "w+");   
  fp_C24_0 = fopen("mem_C24_0.txt", "w+");
  fp_C24_1 = fopen("mem_C24_1.txt", "w+");
  fp_XP_0 =  fopen("mem_XP_0.txt", "w+");
  fp_XP_1 =  fopen("mem_XP_1.txt", "w+");  
  fp_ZP_0 =  fopen("mem_ZP_0.txt", "w+");
  fp_ZP_1 =  fopen("mem_ZP_1.txt", "w+");

  for (int i=0; i<NWORDS_FIELD; i++) {
    fprintf(fp_A24_0, "%08x\n", A24_0[i]);
    fprintf(fp_A24_1, "%08x\n", A24_1[i]);
    fprintf(fp_C24_0, "%08x\n", C24_0[i]);
    fprintf(fp_C24_1, "%08x\n", C24_1[i]);
    fprintf(fp_XP_0, "%08x\n", XP_0[i]);
    fprintf(fp_XP_1, "%08x\n", XP_1[i]);
    fprintf(fp_ZP_0, "%08x\n", ZP_0[i]);
    fprintf(fp_ZP_1, "%08x\n", ZP_1[i]);
  }

  fclose(fp_A24_0);
  fclose(fp_A24_1);  
  fclose(fp_C24_0);
  fclose(fp_C24_1);
  fclose(fp_XP_0);
  fclose(fp_XP_1);
  fclose(fp_ZP_0);
  fclose(fp_ZP_1);
  #endif
*/

  uint64_t t0 = -cpucycles();

  xDBLe(P, P, A24, C24, 4);

  t0 += cpucycles();

  // modular correction to reduce to range [0, p128-1]
  fpcorrection128(XP_0);
  fpcorrection128(XP_1);
  fpcorrection128(ZP_0);
  fpcorrection128(ZP_1);

  printf("\nresult XP_0:\n");

  for (int i=0; i<NWORDS_FIELD; i++) {
    printf("%d    ", i); 
    printf("%x\n", XP_0[i]); 
  }

  printf("\nresult XP_1:\n");

  for (int i=0; i<NWORDS_FIELD; i++) {
    printf("%d    ", i); 
    printf("%x\n", XP_1[i]); 
  }

  printf("\nresult ZP_0:\n");

  for (int i=0; i<NWORDS_FIELD; i++) {
    printf("%d    ", i); 
    printf("%x\n", ZP_0[i]);
  }

  printf("\nresult ZP_1:\n");

  for (int i=0; i<NWORDS_FIELD; i++) {
    printf("%d    ", i); 
    printf("%x\n", ZP_1[i]);
  }

  printf("\n------------PERFORMANCE------------\n\n");
  printf("cycles for xDBLe in sw: %" PRIu64 "\n\n", t0);  


}