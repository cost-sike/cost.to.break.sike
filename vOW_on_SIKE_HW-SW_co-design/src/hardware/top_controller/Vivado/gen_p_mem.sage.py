
# This file was *autogenerated* from the file gen_p_mem.sage
from sage.all_cmdline import *   # import sage library

_sage_const_3 = Integer(3); _sage_const_2 = Integer(2); _sage_const_1 = Integer(1); _sage_const_0 = Integer(0); _sage_const_610 = Integer(610); _sage_const_4 = Integer(4); _sage_const_503 = Integer(503); _sage_const_23 = Integer(23); _sage_const_20 = Integer(20); _sage_const_137 = Integer(137); _sage_const_117 = Integer(117); _sage_const_239 = Integer(239); _sage_const_159 = Integer(159); _sage_const_192 = Integer(192); _sage_const_191 = Integer(191); _sage_const_216 = Integer(216); _sage_const_377 = Integer(377); _sage_const_448 = Integer(448); _sage_const_250 = Integer(250); _sage_const_372 = Integer(372); _sage_const_32 = Integer(32); _sage_const_128 = Integer(128); _sage_const_751 = Integer(751); _sage_const_434 = Integer(434); _sage_const_305 = Integer(305)# generate memory contents for c_1, which equals to p

import sys
import argparse 
import random

parser = argparse.ArgumentParser(description='Montgomery multiplication software.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument('-w', '--w', dest='w', type=int, default=_sage_const_32 ,
          help='radix w')
parser.add_argument('-prime', '--prime', dest='prime', type=int, default=_sage_const_434 ,
          help='prime width')
parser.add_argument('-R', '--R', dest='R', type=int, default=_sage_const_448 ,
          help='rounded prime width') 
parser.add_argument('-sw', dest='sw', type=int, default=_sage_const_0 ,
          help='width of sk')       
parser.add_argument('-sd', dest='sd', type=int, default=_sage_const_0 ,
          help='depth of sk') 
args = parser.parse_args()
 
# radix, can be 8, 16, 32, 64, etc, need to be careful about overflow 
w=args.w
prime=args.prime
R=args.R
sk_width=args.sw
sk_depth=args.sd


format_element = "{0:0" + str(w) +"b}"

if (prime == _sage_const_128 ): 
    p = _sage_const_2 **_sage_const_32 *_sage_const_3 **_sage_const_20 *_sage_const_23 -_sage_const_1 
elif (prime == _sage_const_377 ):
    p = _sage_const_2 **_sage_const_191 *_sage_const_3 **_sage_const_117 -_sage_const_1 
elif (prime == _sage_const_434 ): 
    p = _sage_const_2 **_sage_const_216 *_sage_const_3 **_sage_const_137 -_sage_const_1   
elif (prime == _sage_const_503 ):
    p = _sage_const_2 **_sage_const_250 *_sage_const_3 **_sage_const_159 -_sage_const_1  
elif (prime == _sage_const_610 ):
    p = _sage_const_2 **_sage_const_305 *_sage_const_3 **_sage_const_192 -_sage_const_1 
elif (prime == _sage_const_751 ):
    p = _sage_const_2 **_sage_const_372 *_sage_const_3 **_sage_const_239 -_sage_const_1  
else:
  print "Error!!\n\n  Please specify a valid value for prime p!\n"

# Finite field
Fp = GF(p)

# number of digits in operands a and b
n = int(R/w)
 

f_c_1 = open("mem_p_plus_one.mem", "w"); 

Z = IntegerRing()

m = [Z(_sage_const_0 )]*n

for i in range(n):
    m[i] = ((p+_sage_const_1 ) >> (w*i)) % _sage_const_2 **w 
    f_c_1.write(format_element.format(m[i]))
    f_c_1.write("\n")

f_c_1.close()

# write value 2*p to a file
t = _sage_const_2 *p

ot = [Z(_sage_const_0 )]*n 

f_t = open("px2.mem", "w"); 

for i in range(n):  
    ot[i] = Z((Z(t) >> (w*i)) % _sage_const_2 **w) 
    f_t.write(format_element.format(ot[i]))
    f_t.write("\n") 

f_t.close() 

# write value 4*p to a file
t = _sage_const_4 *p

ot = [Z(_sage_const_0 )]*n 

f_t = open("px4.mem", "w"); 

for i in range(n):  
    ot[i] = Z((Z(t) >> (w*i)) % _sage_const_2 **w) 
    f_t.write(format_element.format(ot[i]))
    f_t.write("\n") 

f_t.close() 

# generate sk array and write to memory
sk = [_sage_const_0 ]*(sk_width*sk_depth)
f = open("sk.mem", "w")
for i in range(sk_depth):
  sk_string = ""
  for j in range(sk_width):
    #print i, j
    sk[i*sk_width+j] = random.randint(_sage_const_0 ,_sage_const_1 )
    sk_string = str(sk[i*sk_width+j]) + sk_string
  f.write(sk_string) 
  f.write("\n")
f.close()

