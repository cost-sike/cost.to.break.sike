
#ifndef SHAKE256_HARDWARE_H
#define SHAKE256_HARDWARE_H
 
#include <stddef.h>
#include <stdint.h>

#define CONTROL_BIT 1 // address offset = 4
#define DIN_BIT 2 // address offset = 8 
#define DIN_READY_BIT 1 // address offset = 4
#define DOUT_VALID_BIT 2 // address offset = 8
#define DOUT_BIT 3 // address offset = 12
#define RESET 1 
#define SHAKE_256_RATE 1088
#define SHAKE_256_RATE_BYTE 136
#define SHAKE_256_RATE_WORD 34
#define CMD 1

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
                    unsigned long long outlen); // in bytes)  
                    
#endif  
