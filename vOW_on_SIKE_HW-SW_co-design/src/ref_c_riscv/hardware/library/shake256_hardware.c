#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <shake256_hardware.h>
#include <murax.h>
#include <sys/stat.h>
#include <inttypes.h>
 
volatile uint32_t *ctrl_shake256 = (uint32_t*)0xf0040000;  
 
/**
 * \brief            This function communicates with the shake hardware module 
 * \input            cshake = 1 -> cshake; cshake = 0 -> shake
 * \input            cstm -> domain separator for cshake
 * \input            byte string of length inlen
 * \output           byte string of length outlen
**/
 
void shake256_hardware(uint32_t cshake,
                    uint16_t cstm,
                    const unsigned char *input,
                    unsigned long long inlen, // in bytes
                    unsigned char *output,
                    unsigned long long outlen) // in bytes)  
{
  
  int i, j;
  int sent_word_counter = 0;
  int din_total_rate_chunk = (inlen/SHAKE_256_RATE_BYTE);
  int total_word_in = ((inlen+3)/4);
  int dout_total_rate_chunk = (outlen/SHAKE_256_RATE_BYTE);
  int total_word_out = ((outlen+3)/4); 
  int last_indata_word_mask;
  int last_block_short;

  last_block_short = (outlen % SHAKE_256_RATE_BYTE);
 
  // the unused high bits in the last 32-bit word sent should be 0, otherwise there is error
  if ((inlen % 4) == 0) {
    last_indata_word_mask = 0xffffffff;
  } else if ((inlen % 4) == 1) {
    last_indata_word_mask = 0x000000ff;
  } else if ((inlen % 4) == 2) {
    last_indata_word_mask = 0x0000ffff;
  } else {
    last_indata_word_mask = 0x00ffffff;
  }

  volatile uint32_t *data = &ctrl_shake256[DIN_BIT];
  
  // reset shake hw core
  ctrl_shake256[CONTROL_BIT] = (RESET << 3) | (CMD << 8);
 
  // send inputs
    // send the first 32-bit block, encoded as:
      // bit 31 = 0 => shake; bit 31 = 1 => cshake
      // bit 30:0 => output string length in bit!!
      // have to round it a muktiple of 32 to make sure the output is right
  if (cshake == 1) {
    data[0] = (0xC0000000 | (total_word_out << 5));
    data[0] = (uint32_t) cstm;
  }
  else {
    data[0] = (uint32_t) (0x40000000 | (total_word_out << 5));
  }
  
  // first divide inputs based on the size of shake rate, then send the chunks one by one
    // a new length = rate chunk
  for (i = 0; i < din_total_rate_chunk; i++) {
    
    // wait till the core is ready to accept data
    while(ctrl_shake256[DIN_READY_BIT] == 0);
    
    // send chunk length in bits, bit 31 = 0
    data[0] = SHAKE_256_RATE;
    
    // send real data
    // 32-bit words within the chunk
    for (j = 0; j < SHAKE_256_RATE_WORD; j++) {
      data[0] = ((uint32_t*)input)[sent_word_counter];
      sent_word_counter += 1;
    }
  }

  // the last chunk, send remaining words

  // wait till the core is ready to accept data
  while(ctrl_shake256[DIN_READY_BIT] == 0);

  // send chunk length in bits + EOF sign
  data[0] = (1 << 31) + ((inlen - (sent_word_counter << 2)) << 3);

  for (i = sent_word_counter; i < (total_word_in-1); i++) {
    data[0] = ((uint32_t*)input)[i];
  }

  data[0] = ((uint32_t*)input)[total_word_in-1] & last_indata_word_mask;
 
  sent_word_counter = 0;
   
  // // wait till the output is valid
  // while(ctrl_shake256[DOUT_VALID_BIT] == 0);

  // for (i = 0; i < total_word_out; i++) {
  //   ((uint32_t*)output)[i] = ctrl_shake256[DOUT_BIT];
  // }

  // receive result back 
  for (i = 0; i < dout_total_rate_chunk; i++) {
    // wait till the output is valid
    while(ctrl_shake256[DOUT_VALID_BIT] == 0);

    for (j = 0; j < SHAKE_256_RATE_WORD; j++) {
      ((uint32_t*)output)[sent_word_counter] = ctrl_shake256[DOUT_BIT];
      sent_word_counter += 1;
    } 
  }
  
  if (last_block_short) {
    // wait till the output is valid
    while(ctrl_shake256[DOUT_VALID_BIT] == 0);

    for (i = sent_word_counter; i < total_word_out; i++) {
      ((uint32_t*)output)[i] = ctrl_shake256[DOUT_BIT];
    }  
  }

}