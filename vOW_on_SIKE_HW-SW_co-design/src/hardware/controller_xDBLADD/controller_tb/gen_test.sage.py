
# This file was *autogenerated* from the file gen_test.sage
from sage.all_cmdline import *   # import sage library

_sage_const_3 = Integer(3); _sage_const_2 = Integer(2); _sage_const_1 = Integer(1); _sage_const_0 = Integer(0); _sage_const_610 = Integer(610); _sage_const_546 = Integer(546); _sage_const_4 = Integer(4); _sage_const_503 = Integer(503); _sage_const_23 = Integer(23); _sage_const_20 = Integer(20); _sage_const_697 = Integer(697); _sage_const_172 = Integer(172); _sage_const_215 = Integer(215); _sage_const_137 = Integer(137); _sage_const_117 = Integer(117); _sage_const_239 = Integer(239); _sage_const_159 = Integer(159); _sage_const_192 = Integer(192); _sage_const_191 = Integer(191); _sage_const_273 = Integer(273); _sage_const_216 = Integer(216); _sage_const_377 = Integer(377); _sage_const_448 = Integer(448); _sage_const_250 = Integer(250); _sage_const_372 = Integer(372); _sage_const_356 = Integer(356); _sage_const_32 = Integer(32); _sage_const_128 = Integer(128); _sage_const_751 = Integer(751); _sage_const_434 = Integer(434); _sage_const_305 = Integer(305)
import sys
import argparse 
import random

parser = argparse.ArgumentParser(description='xDBLADD_hw software.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument('-w', '--w', dest='w', type=int, default=_sage_const_32 ,
          help='radix w')
parser.add_argument('-s', '--seed', dest='seed', type=int, required=False, default=None,
          help='seed')
parser.add_argument('-prime', '--prime', dest='prime', type=int, default=_sage_const_434 ,
          help='prime width')
parser.add_argument('-R', '--R', dest='R', type=int, default=_sage_const_448 ,
          help='rounded prime width')
args = parser.parse_args()

if args.seed:
  set_random_seed(args.seed)
  random.seed(args.seed)

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
elif (prime == _sage_const_546 ):
    p = _sage_const_2 **_sage_const_273 *_sage_const_3 **_sage_const_172 -_sage_const_1 
elif (prime == _sage_const_697 ):
    p = _sage_const_2 **_sage_const_356 *_sage_const_3 **_sage_const_215 -_sage_const_1  
else:
  print "Error!!\n\n  Please specify a valid value for prime p!\n" 

# Finite field
Fp = GF(p)

# number of digits in operands a and b
n = int(log(R,_sage_const_2 )/w)

# force unsigned arithmetic
Z = IntegerRing()
Fr = IntegerModRing(R)
pp = Fr(-p**-_sage_const_1 )
assert((pp % _sage_const_2 **w) == _sage_const_1 )

OK=true

# define a class for GF(p^2) field
class Fp2_element:
#  def __init__(self, realpart, imagpart):
    r = Z(_sage_const_0 )
    i = Z(_sage_const_0 )

def fp2_random_init(a):
  a.r = Z(random.randint(_sage_const_0 , _sage_const_2 *p))
  a.i = Z(random.randint(_sage_const_0 , _sage_const_2 *p))
  return a
 

def fp_mont_mul_add(a0, a1, b0, b1):
  oa0 = [Z(_sage_const_0 )]*n
  ob0 = [Z(_sage_const_0 )]*n
  oa1 = [Z(_sage_const_0 )]*n
  ob1 = [Z(_sage_const_0 )]*n  

  m = [Z(_sage_const_0 )]*n  

  for i in range(n):
      m[i] = ((p+_sage_const_1 ) >> (w*i)) % _sage_const_2 **w 
   
  for i in range(n):  
      oa0[i] = Z((Z(a0) >> (w*i)) % _sage_const_2 **w)  
      ob0[i] = Z((Z(b0) >> (w*i)) % _sage_const_2 **w) 
      oa1[i] = Z((Z(a1) >> (w*i)) % _sage_const_2 **w) 
      ob1[i] = Z((Z(b1) >> (w*i)) % _sage_const_2 **w) 

  # actual Montgomery multiplication algorithm
  # CS = (C, S), C is (w+1)-bits, and S is w bits. C gets sign-extended for addition in the inner j loop
  t = [Z(_sage_const_0 )]*n 
  for i in range(n): 
      CS = oa0[_sage_const_0 ]*ob1[i] + oa1[_sage_const_0 ]*ob0[i] + t[_sage_const_0 ]  
      S = CS % _sage_const_2 **w
      C = CS >> w 
      mm = S
      for j in range(_sage_const_1 , n): 
          CS = oa0[j]*ob1[i] + oa1[j]*ob0[i] + mm*m[j] + t[j] + C  
          S = CS % _sage_const_2 **w
          C = CS >> w
          t[j-_sage_const_1 ] = S 
      t[n-_sage_const_1 ] = C 
    
  # Assembling result, not needed in hw
  e = _sage_const_0 
  for i in range(n):
      e += t[i]*_sage_const_2 **(w*i)

  assert(e >= _sage_const_0 )
  assert(e <= _sage_const_2 *p) 

  # conversion to standard form
  ee = Fp(e*R)

  # direct result, for comparison
  c = Fp(a0*b1+a1*b0) 

  # verification of results
  assert(Z(c) == Z(ee))
 
  return e

def fp_mont_mul_sub(a0, a1, b0, b1):
  oa0 = [Z(_sage_const_0 )]*n
  ob0 = [Z(_sage_const_0 )]*n
  oa1 = [Z(_sage_const_0 )]*n
  ob1 = [Z(_sage_const_0 )]*n  

  m = [Z(_sage_const_0 )]*n  

  for i in range(n):
      m[i] = ((p+_sage_const_1 ) >> (w*i)) % _sage_const_2 **w 
   
  for i in range(n):  
      oa0[i] = Z((Z(a0) >> (w*i)) % _sage_const_2 **w)  
      ob0[i] = Z((Z(b0) >> (w*i)) % _sage_const_2 **w) 
      oa1[i] = Z((Z(a1) >> (w*i)) % _sage_const_2 **w) 
      ob1[i] = Z((Z(b1) >> (w*i)) % _sage_const_2 **w) 

  # actual Montgomery multiplication algorithm
  # CS = (C, S), C is (w+1)-bits, and S is w bits. C gets sign-extended for addition in the inner j loop
  t = [Z(_sage_const_0 )]*n 
  for i in range(n): 
      CS = oa0[_sage_const_0 ]*ob0[i] - oa1[_sage_const_0 ]*ob1[i] + t[_sage_const_0 ]  
      S = CS % _sage_const_2 **w
      C = CS >> w 
      mm = S
      for j in range(_sage_const_1 , n): 
          CS = oa0[j]*ob0[i] - oa1[j]*ob1[i] + mm*m[j] + t[j] + C  
          S = CS % _sage_const_2 **w
          C = CS >> w
          t[j-_sage_const_1 ] = S 
      t[n-_sage_const_1 ] = C 
    
  # Assembling result, not needed in hw
  e = _sage_const_0 
  for i in range(n):
      e += t[i]*_sage_const_2 **(w*i)

  # check if sub result is negative and correct it to being positive
  if (e < _sage_const_0 ):
    print "\nresult e is SMALLER than 0!\n"
    e += _sage_const_2 *p
  assert(e >= _sage_const_0 )
  assert(e <= _sage_const_2 *p) 

  # conversion to standard form
  ee = Fp(e*R)

  # direct result, for comparison
  c = Fp(a0*b0-a1*b1) 

  # verification of results
  assert(Z(c) == Z(ee))
 
  return e

def fp2_mult(a, b): 
  c = Fp2_element()
  a0 = a.r
  a1 = a.i
  b0 = b.r
  b1 = b.i
  c0 = fp_mont_mul_sub(a0, a1, b0, b1)
  c1 = fp_mont_mul_add(a0, a1, b0, b1)
  #c0 = Fp(a0*b0-a1*b1)
  #c1 = Fp(a0*b1+a1*b0)
  c.r = c0
  c.i = c1
  return c

def fp2_add(a, b):
  c = Fp2_element()
  a0 = a.r
  a1 = a.i
  b0 = b.r
  b1 = b.i
  c0 = a0+b0
  c1 = a1+b1
  if (c0 >= _sage_const_2 *p):
    c0 -= _sage_const_2 *p
  if (c1 >= _sage_const_2 *p):
    c1 -= _sage_const_2 *p
  c.r = c0
  c.i = c1
  return c

def fp2_sub(a, b):
  c = Fp2_element()
  a0 = a.r
  a1 = a.i
  b0 = b.r
  b1 = b.i
  c0 = a0-b0
  c1 = a1-b1
  if (c0 < _sage_const_0 ):
    c0 += _sage_const_2 *p
  if (c1 < _sage_const_0 ):
    c1 += _sage_const_2 *p
  c.r = c0
  c.i = c1
  return c


def xDBLADD(XP,ZP,XQ,ZQ,xPQ,zPQ,A24):
  t0 = Fp2_element()
  t1 = Fp2_element()
  t2 = Fp2_element()
  t3 = Fp2_element()
  t4 = Fp2_element()
  t5 = Fp2_element()
  t6 = Fp2_element()
  t7 = Fp2_element()
  t8 = Fp2_element()
  t0 = fp2_add(XP,ZP)
  t1 = fp2_sub(XP,ZP)
  t2 = fp2_add(XQ,ZQ)
  t3 = fp2_sub(XQ,ZQ)
  t6 = fp2_mult(t0,t3)      
  t7 = fp2_mult(t1,t2)          
  t2 = fp2_mult(t0,t0)           
  t3 = fp2_mult(t1,t1)           
  t0 = fp2_sub(t2,t3)
  t1 = fp2_sub(t6,t7)
  t4 = fp2_mult(A24,t0)         
  t5 = fp2_mult(t2,t3)           
  t2 = fp2_add(t4,t3)
  t8 = fp2_add(t6,t7)
  t3 = fp2_mult(t1,t1)        
  t4 = fp2_mult(t8,t8)          
  t1 = fp2_mult(t2,t0)         
  t6 = fp2_mult(xPQ,t3)
  t4 = fp2_mult(zPQ,t4)      
  return t5,t1,t4,t6
 
 

def xDBLADD_hw(XP,ZP,XQ,ZQ,xPQ,zPQ,A24):
  t0 = Fp2_element()
  t1 = Fp2_element()
  t2 = Fp2_element()
  t3 = Fp2_element()
  t4 = Fp2_element()
  t5 = Fp2_element() 
  t6 = Fp2_element()
  t7 = Fp2_element()
  t8 = Fp2_element()
  t9 = Fp2_element()
  t10 = Fp2_element() 

  t0 = fp2_add(XP,ZP)
  t1 = fp2_sub(XP,ZP)
  
  t4 = t0
  t5 = t1
  #fp2_write_to_file(t4, n, "0-sage_xDBLADD_t4_0.txt", "0-sage_xDBLADD_t4_1.txt")
  #fp2_write_to_file(t5, n, "0-sage_xDBLADD_t5_0.txt", "0-sage_xDBLADD_t5_1.txt")
  t0 = fp2_add(XQ,ZQ)
  t1 = fp2_sub(XQ,ZQ)

  t2 = fp2_mult(t1,t4)           
  t3 = fp2_mult(t0,t5)          
  
  t6 = t2
  t7 = t3
  t2 = fp2_mult(t4,t4)          
  t3 = fp2_mult(t5,t5)           

  t4 = t2                               
  t5 = t3      
  #fp2_write_to_file(t4, n, "1-sage_xDBLADD_t4_0.txt", "1-sage_xDBLADD_t4_1.txt")
  #fp2_write_to_file(t5, n, "1-sage_xDBLADD_t5_0.txt", "1-sage_xDBLADD_t5_1.txt")                         
  t0 = fp2_sub(t2,t3)
  t1 = fp2_sub(t6,t7)                            
  
  t8 = t0                              
  t9 = t1    
  #fp2_write_to_file(t8, n, "0-sage_xDBLADD_t8_0.txt", "0-sage_xDBLADD_t8_1.txt")
  #fp2_write_to_file(t9, n, "0-sage_xDBLADD_t9_0.txt", "0-sage_xDBLADD_t9_1.txt")  

  t2 = fp2_mult(t4,t5)          
  t3 = fp2_mult(t0,A24)         
  
  t10 = t2 
  t4 = t3
  t0 = fp2_add(t5,t3)                                            
  t1 = fp2_add(t6,t7)                             

  t2 = fp2_mult(t1,t1)         
  t3 = fp2_mult(t9,t9)           
  
  t5 = t3
  t4 = t2
  #fp2_write_to_file(t4, n, "2-sage_xDBLADD_t4_0.txt", "2-sage_xDBLADD_t4_1.txt")
  #fp2_write_to_file(t5, n, "2-sage_xDBLADD_t5_0.txt", "2-sage_xDBLADD_t5_1.txt")

  t2 = fp2_mult(t0,t8)        
  t3 = fp2_mult(xPQ,t5) 

  t5 = t2
  
  t2 = fp2_mult(t4,zPQ)

  return t10,t5,t2,t3


 

def fp2_write_to_file(a, n, FILE_NAME_0, FILE_NAME_1):
  fp0 = open(FILE_NAME_0, "w")
  fp1 = open(FILE_NAME_1, "w")
  a0 = a.r
  a1 = a.i
  oa0 = [Z(_sage_const_0 )]*n
  oa1 = [Z(_sage_const_0 )]*n
  for i in range(n):
    oa0[i] = Z((Z(a0) >> (w*i)) % _sage_const_2 **w)
    fp0.write(format_element.format(oa0[i]))
    fp0.write("\n")
    oa1[i] = Z((Z(a1) >> (w*i)) % _sage_const_2 **w)
    fp1.write(format_element.format(oa1[i]))
    fp1.write("\n")
  fp0.close()
  fp1.close()

def fp_write_to_file(a, FILE_NAME):
  fp = open(FILE_NAME, "w") 
  m = [Z(_sage_const_0 )]*n 
  for i in range(n):
    m[i] = Z((Z(a) >> (w*i)) % _sage_const_2 **w)
    fp.write(format_element.format(m[i]))
    fp.write("\n") 
  fp.close() 

# write constants to memory
fp_write_to_file(p+_sage_const_1 , "mem_p_plus_one.mem")
fp_write_to_file(_sage_const_2 *p, "px2.mem")
fp_write_to_file(_sage_const_4 *p, "px4.mem")


XP = Fp2_element()
ZP = Fp2_element()
XQ = Fp2_element()
ZQ = Fp2_element()
A24 = Fp2_element()
xPQ = Fp2_element()
zPQ = Fp2_element()

XP = fp2_random_init(XP)
ZP = fp2_random_init(ZP)
XQ = fp2_random_init(XQ)
ZQ = fp2_random_init(ZQ)
A24 = fp2_random_init(A24)
xPQ = fp2_random_init(xPQ)
zPQ = fp2_random_init(zPQ)
 
fp2_write_to_file(XP, n, "xDBLADD_mem_XP_0.txt", "xDBLADD_mem_XP_1.txt")
fp2_write_to_file(ZP, n, "xDBLADD_mem_ZP_0.txt", "xDBLADD_mem_ZP_1.txt")
fp2_write_to_file(XQ, n, "xDBLADD_mem_XQ_0.txt", "xDBLADD_mem_XQ_1.txt")
fp2_write_to_file(ZQ, n, "xDBLADD_mem_ZQ_0.txt", "xDBLADD_mem_ZQ_1.txt")
fp2_write_to_file(A24, n, "xDBLADD_mem_A24_0.txt", "xDBLADD_mem_A24_1.txt")
fp2_write_to_file(xPQ, n, "xDBLADD_mem_xPQ_0.txt", "xDBLADD_mem_xPQ_1.txt")
fp2_write_to_file(zPQ, n, "xDBLADD_mem_zPQ_0.txt", "xDBLADD_mem_zPQ_1.txt")

# check if the hw-friendly sage function fits to the software one
(a, b, c, d) = xDBLADD(XP,ZP,XQ,ZQ,xPQ,zPQ,A24)  

(e, f, g, h) = xDBLADD_hw(XP,ZP,XQ,ZQ,xPQ,zPQ,A24) 

assert((a.r, a.i) == (e.r, e.i))
assert((b.r, b.i) == (f.r, f.i))
assert((c.r, c.i) == (g.r, g.i))
assert((d.r, d.i) == (h.r, h.i))

(t10,t5,t2,t3) = xDBLADD_hw(XP,ZP,XQ,ZQ,xPQ,zPQ,A24)

fp2_write_to_file(t10, n, "sage_xDBLADD_t10_0.txt", "sage_xDBLADD_t10_1.txt")
fp2_write_to_file(t5, n, "sage_xDBLADD_t5_0.txt", "sage_xDBLADD_t5_1.txt")
fp2_write_to_file(t2, n, "sage_xDBLADD_t2_0.txt", "sage_xDBLADD_t2_1.txt") 
fp2_write_to_file(t3, n, "sage_xDBLADD_t3_0.txt", "sage_xDBLADD_t3_1.txt") 

 






