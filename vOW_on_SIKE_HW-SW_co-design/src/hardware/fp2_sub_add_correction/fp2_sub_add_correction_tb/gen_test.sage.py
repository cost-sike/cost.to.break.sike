
# This file was *autogenerated* from the file gen_test.sage
from sage.all_cmdline import *   # import sage library

_sage_const_3 = Integer(3); _sage_const_2 = Integer(2); _sage_const_1 = Integer(1); _sage_const_0 = Integer(0); _sage_const_610 = Integer(610); _sage_const_5 = Integer(5); _sage_const_4 = Integer(4); _sage_const_503 = Integer(503); _sage_const_23 = Integer(23); _sage_const_20 = Integer(20); _sage_const_137 = Integer(137); _sage_const_117 = Integer(117); _sage_const_239 = Integer(239); _sage_const_159 = Integer(159); _sage_const_192 = Integer(192); _sage_const_191 = Integer(191); _sage_const_216 = Integer(216); _sage_const_377 = Integer(377); _sage_const_448 = Integer(448); _sage_const_250 = Integer(250); _sage_const_372 = Integer(372); _sage_const_32 = Integer(32); _sage_const_128 = Integer(128); _sage_const_751 = Integer(751); _sage_const_434 = Integer(434); _sage_const_305 = Integer(305)# converted from Magma script

import sys
import argparse
import random 

parser = argparse.ArgumentParser(description='generate test inputs for adder/comparator.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument('-w', '--w', dest='w', type=int, default=_sage_const_32 ,
          help='radix w')
parser.add_argument('-s', '--seed', dest='seed', type=int, required=False, default=None,
          help='seed')
parser.add_argument('-prime', '--prime', dest='prime', type=int, default=_sage_const_434 ,
          help='prime width')
parser.add_argument('-R', '--R', dest='R', type=int, default=_sage_const_448 ,
          help='rounded prime width')
parser.add_argument('-cmd', '--cmd', dest='cmd', type=int, default=_sage_const_1 ,
          help='cmd')
parser.add_argument('-ef', '--ef', dest='extension_field', type=int, default=_sage_const_0 ,
          help='if it is operation on extension field')
args = parser.parse_args()

if args.seed:
  set_random_seed(args.seed)
  random.seed(args.seed)

cmd = args.cmd
extension_field = args.extension_field

# radix, can be 8, 16, 32, 64, etc, need to be careful about overflow 
w=args.w 
prime=args.prime
R=_sage_const_2 **(args.R)

hex_format_element = "{0:0" + str(w/_sage_const_4 ) +"x}"
format_element = "{0:0" + str(w) +"b}"

# pick a prime:
# testing purpose
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
n = int(log(R,_sage_const_2 )/w)

# force unsigned arithmetic
Z = IntegerRing() 

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

# generate random inputs in specified range for different functions
if (cmd == _sage_const_3 ):
  a0 = Z(random.randint(_sage_const_0 , _sage_const_32 *p))
  b0 = Z(random.randint(_sage_const_0 , _sage_const_32 *p))
elif (cmd == _sage_const_5 ):
  a0 = Z(random.randint(_sage_const_0 , _sage_const_4 *p))
  b0 = Z(random.randint(_sage_const_0 , _sage_const_4 *p)) 
else:
  a0 = Z(random.randint(_sage_const_0 , _sage_const_2 *p))
  b0 = Z(random.randint(_sage_const_0 , _sage_const_2 *p))

if (extension_field == _sage_const_1 ):
  if (cmd == _sage_const_3 ):
    a1 = Z(random.randint(_sage_const_0 , _sage_const_32 *p))
    b1 = Z(random.randint(_sage_const_0 , _sage_const_32 *p))
  elif (cmd == _sage_const_5 ):
    a1 = Z(random.randint(_sage_const_0 , _sage_const_4 *p))
    b1 = Z(random.randint(_sage_const_0 , _sage_const_4 *p)) 
  else:
    a1 = Z(random.randint(_sage_const_0 , _sage_const_2 *p))
    b1 = Z(random.randint(_sage_const_0 , _sage_const_2 *p))

# write digits in a and b into files
oa = [Z(_sage_const_0 )]*n
ob = [Z(_sage_const_0 )]*n

f_a = open("Sage_mem_a_0.txt", "w");
f_b = open("Sage_mem_b_0.txt", "w");

for i in range(n):  
    oa[i] = Z((Z(a0) >> (w*i)) % _sage_const_2 **w)
    ob[i] = Z((Z(b0) >> (w*i)) % _sage_const_2 **w)
    f_a.write(hex_format_element.format(oa[i]))
    f_a.write("\n")
    f_b.write(hex_format_element.format(ob[i]))
    f_b.write("\n")

f_a.close()
f_b.close()

if (extension_field == _sage_const_1 ):
  # write digits in a and b into files
  oa = [Z(_sage_const_0 )]*n
  ob = [Z(_sage_const_0 )]*n

  f_a = open("Sage_mem_a_1.txt", "w");
  f_b = open("Sage_mem_b_1.txt", "w");

  for i in range(n):  
      oa[i] = Z((Z(a1) >> (w*i)) % _sage_const_2 **w)
      ob[i] = Z((Z(b1) >> (w*i)) % _sage_const_2 **w)
      f_a.write(hex_format_element.format(oa[i]))
      f_a.write("\n")
      f_b.write(hex_format_element.format(ob[i]))
      f_b.write("\n")

  f_a.close()
  f_b.close()

# result of different functions
if (cmd == _sage_const_1 ):
  c0 = Z(a0+b0)
  if (c0 > _sage_const_2 *p):
    c0 -= _sage_const_2 *p
elif (cmd == _sage_const_2 ):
  c0 = Z(a0-b0)
  if (c0 < _sage_const_0 ):
    c0 += _sage_const_2 *p
elif (cmd == _sage_const_3 ):
  c0 = Z(a0+b0)
elif (cmd == _sage_const_4 ):
  c0 = Z(a0-b0)+_sage_const_2 *p
elif (cmd == _sage_const_5 ):
  c0 = Z(a0-b0)+_sage_const_4 *p
else:
  print "Please choose a valid cmd!\n"
 
# write digits in c into files
oc = [Z(_sage_const_0 )]*n 

f_c = open("Sage_c_0.txt", "w"); 

for i in range(n):  
    oc[i] = Z((Z(c0) >> (w*i)) % _sage_const_2 **w) 
    f_c.write(hex_format_element.format(oc[i]))
    f_c.write("\n") 

f_c.close() 

if (extension_field == _sage_const_1 ):
   # result of different functions
  if (cmd == _sage_const_1 ):
    c1 = Z(a1+b1)
    if (c1 > _sage_const_2 *p):
      c1 -= _sage_const_2 *p
  elif (cmd == _sage_const_2 ):
    c1 = Z(a1-b1)
    if (c1 < _sage_const_0 ):
      c1 += _sage_const_2 *p
  elif (cmd == _sage_const_3 ):
    c1 = Z(a1+b1)
  elif (cmd == _sage_const_4 ):
    c1 = Z(a1-b1)+_sage_const_2 *p
  elif (cmd == _sage_const_5 ):
    c1 = Z(a1-b1)+_sage_const_4 *p
  else:
    print "Please choose a valid cmd!\n"
   
  # write digits in c into files
  oc = [Z(_sage_const_0 )]*n 

  f_c = open("Sage_c_1.txt", "w"); 

  for i in range(n):  
      oc[i] = Z((Z(c1) >> (w*i)) % _sage_const_2 **w) 
      f_c.write(hex_format_element.format(oc[i]))
      f_c.write("\n") 

  f_c.close() 


 
