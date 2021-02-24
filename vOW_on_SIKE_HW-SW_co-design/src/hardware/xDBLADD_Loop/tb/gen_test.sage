import sys
import argparse 
import random

parser = argparse.ArgumentParser(description='xDBL_hw software.',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument('-w', '--w', dest='w', type=int, default=32,
          help='radix w')
parser.add_argument('-s', '--seed', dest='seed', type=int, required=False, default=None,
          help='seed')
parser.add_argument('-prime', '--prime', dest='prime', type=int, default=434,
          help='prime width')
parser.add_argument('-R', '--R', dest='R', type=int, default=448,
          help='rounded prime width')
parser.add_argument('-b', dest='b', type=int, default=0,
          help='start index of the loop') 
parser.add_argument('-e', dest='e', type=int, default=0,
          help='end index of the loop')   
parser.add_argument('-sw', dest='sw', type=int, default=0,
          help='width of sk')       
parser.add_argument('-sd', dest='sd', type=int, default=0,
          help='depth of sk')  
args = parser.parse_args()

if args.seed:
  set_random_seed(args.seed)
  random.seed(args.seed)

# radix, can be 8, 16, 32, 64, etc, need to be careful about overflow 
w=args.w 
prime=args.prime
R=2^(args.R)
start_index=args.b 
end_index=(args.e)+1 
sk_width=args.sw
sk_depth=args.sd

hex_format_element = "{0:0" + str(w/4) +"x}"
format_element = "{0:0" + str(w) +"b}"

# pick a prime:
# testing purpose
if (prime == 128): 
    p = 2^32*3^20*23-1
elif (prime == 377):
    p = 2^191*3^117-1
elif (prime == 434): 
    p = 2^216*3^137-1  
elif (prime == 503):
    p = 2^250*3^159-1 
elif (prime == 610):
    p = 2^305*3^192-1
elif (prime == 751):
    p = 2^372*3^239-1 
else:
  print "Error!!\n\n  Please specify a valid value for prime p!\n"

# Finite field
Fp = GF(p)

# number of digits in operands a and b
n = int(log(R,2)/w)

# force unsigned arithmetic
Z = IntegerRing()
Fr = IntegerModRing(R)
pp = Fr(-p^-1)
assert((pp % 2^w) == 1)

OK=true

# define a class for GF(p^2) field
class Fp2_element:
#  def __init__(self, realpart, imagpart):
    r = Z(0)
    i = Z(0)

def fp2_random_init(a):
  a.r = Z(random.randint(0, 2*p))
  a.i = Z(random.randint(0, 2*p))
  return a
 

def fp_mont_mul_add(a0, a1, b0, b1):
  oa0 = [Z(0)]*n
  ob0 = [Z(0)]*n
  oa1 = [Z(0)]*n
  ob1 = [Z(0)]*n  

  m = [Z(0)]*n  

  for i in range(n):
      m[i] = ((p+1) >> (w*i)) % 2^w 
   
  for i in range(n):  
      oa0[i] = Z((Z(a0) >> (w*i)) % 2^w)  
      ob0[i] = Z((Z(b0) >> (w*i)) % 2^w) 
      oa1[i] = Z((Z(a1) >> (w*i)) % 2^w) 
      ob1[i] = Z((Z(b1) >> (w*i)) % 2^w) 

  # actual Montgomery multiplication algorithm
  # CS = (C, S), C is (w+1)-bits, and S is w bits. C gets sign-extended for addition in the inner j loop
  t = [Z(0)]*n 
  for i in range(n): 
      CS = oa0[0]*ob1[i] + oa1[0]*ob0[i] + t[0]  
      S = CS % 2^w
      C = CS >> w 
      mm = S
      for j in range(1, n): 
          CS = oa0[j]*ob1[i] + oa1[j]*ob0[i] + mm*m[j] + t[j] + C  
          S = CS % 2^w
          C = CS >> w
          t[j-1] = S 
      t[n-1] = C 
    
  # Assembling result, not needed in hw
  e = 0
  for i in range(n):
      e += t[i]*2^(w*i)

  assert(e >= 0)
  assert(e <= 2*p) 

  # conversion to standard form
  ee = Fp(e*R)

  # direct result, for comparison
  c = Fp(a0*b1+a1*b0) 

  # verification of results
  assert(Z(c) == Z(ee))
 
  return e

def fp_mont_mul_sub(a0, a1, b0, b1):
  oa0 = [Z(0)]*n
  ob0 = [Z(0)]*n
  oa1 = [Z(0)]*n
  ob1 = [Z(0)]*n  

  m = [Z(0)]*n  

  for i in range(n):
      m[i] = ((p+1) >> (w*i)) % 2^w 
   
  for i in range(n):  
      oa0[i] = Z((Z(a0) >> (w*i)) % 2^w)  
      ob0[i] = Z((Z(b0) >> (w*i)) % 2^w) 
      oa1[i] = Z((Z(a1) >> (w*i)) % 2^w) 
      ob1[i] = Z((Z(b1) >> (w*i)) % 2^w) 

  # actual Montgomery multiplication algorithm
  # CS = (C, S), C is (w+1)-bits, and S is w bits. C gets sign-extended for addition in the inner j loop
  t = [Z(0)]*n 
  for i in range(n): 
      CS = oa0[0]*ob0[i] - oa1[0]*ob1[i] + t[0]  
      S = CS % 2^w
      C = CS >> w 
      mm = S
      for j in range(1, n): 
          CS = oa0[j]*ob0[i] - oa1[j]*ob1[i] + mm*m[j] + t[j] + C  
          S = CS % 2^w
          C = CS >> w
          t[j-1] = S 
      t[n-1] = C 
    
  # Assembling result, not needed in hw
  e = 0
  for i in range(n):
      e += t[i]*2^(w*i)

  # check if sub result is negative and correct it to being positive
  if (e < 0):
    print "\nresult e is SMALLER than 0!\n"
    e += 2*p
  assert(e >= 0)
  assert(e <= 2*p) 

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
  if (c0 >= 2*p):
    c0 -= 2*p
  if (c1 >= 2*p):
    c1 -= 2*p
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
  if (c0 < 0):
    c0 += 2*p
  if (c1 < 0):
    c1 += 2*p
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

def xDBLADD_loop(XP,ZP,XQ,ZQ,xPQ,zPQ,A24,start_index,end_index,sk):
  for i in range(start_index,end_index):
    if(sk[i] == 0):
      (XP,ZP,XQ,ZQ)=xDBLADD(XP,ZP,XQ,ZQ,xPQ,zPQ,A24)
    else:
      (XP,ZP,xPQ,zPQ)=xDBLADD(XP,ZP,xPQ,zPQ,XQ,ZQ,A24)
  return XP,ZP,XQ,ZQ,xPQ,zPQ


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
  t0 = fp2_sub(t2,t3)
  t1 = fp2_sub(t6,t7)                            
  
  t8 = t0                              
  t9 = t1     

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

  t2 = fp2_mult(t0,t8)        
  t3 = fp2_mult(xPQ,t5) 

  t5 = t2
  
  t2 = fp2_mult(t4,zPQ)

  return t10,t5,t2,t3

def xDBLADD_hw_loop(XP,ZP,XQ,ZQ,xPQ,zPQ,A24,start_index,end_index,sk):
  for i in range(start_index,end_index): 
    if(sk[i] == 0):
      (XP,ZP,XQ,ZQ)=xDBLADD_hw(XP,ZP,XQ,ZQ,xPQ,zPQ,A24)
    else:
      (XP,ZP,xPQ,zPQ)=xDBLADD_hw(XP,ZP,xPQ,zPQ,XQ,ZQ,A24)
    '''
    fp2_write_to_file(XP, n, str(i)+"-mem_XP_0.txt", str(i)+"-mem_XP_1.txt")
    fp2_write_to_file(ZP, n, str(i)+"-mem_ZP_0.txt", str(i)+"-mem_ZP_1.txt")
    fp2_write_to_file(XQ, n, str(i)+"-mem_XQ_0.txt", str(i)+"-mem_XQ_1.txt")
    fp2_write_to_file(ZQ, n, str(i)+"-mem_ZQ_0.txt", str(i)+"-mem_ZQ_1.txt")
    fp2_write_to_file(xPQ, n, str(i)+"-mem_xPQ_0.txt", str(i)+"-mem_xPQ_1.txt")
    fp2_write_to_file(zPQ, n, str(i)+"-mem_zPQ_0.txt", str(i)+"-mem_zPQ_1.txt") 
    '''
  return XP,ZP,XQ,ZQ,xPQ,zPQ

# generate sk array and write to memory
sk = [0]*(sk_width*sk_depth)
f = open("sk.mem", "w")
for i in range(sk_width*sk_depth):
  sk[i] = random.randint(0,1)
  f.write(str(sk[i]))
  if (((i+1) % sk_width) == 0):
    f.write("\n")
f.close()

def fp2_write_to_file(a, n, FILE_NAME_0, FILE_NAME_1):
  fp0 = open(FILE_NAME_0, "w")
  fp1 = open(FILE_NAME_1, "w")
  a0 = a.r
  a1 = a.i
  oa0 = [Z(0)]*n
  oa1 = [Z(0)]*n
  for i in range(n):
    oa0[i] = Z((Z(a0) >> (w*i)) % 2^w)
    fp0.write(hex_format_element.format(oa0[i]))
    fp0.write("\n")
    oa1[i] = Z((Z(a1) >> (w*i)) % 2^w)
    fp1.write(hex_format_element.format(oa1[i]))
    fp1.write("\n")
  fp0.close()
  fp1.close()

def fp_write_to_file(a, FILE_NAME):
  fp = open(FILE_NAME, "w") 
  m = [Z(0)]*n 
  for i in range(n):
    m[i] = Z((Z(a) >> (w*i)) % 2^w)
    fp.write(format_element.format(m[i]))
    fp.write("\n") 
  fp.close() 

# write constants to memory
fp_write_to_file(p+1, "mem_p_plus_one.mem")
fp_write_to_file(2*p, "px2.mem")
fp_write_to_file(4*p, "px4.mem")


XP = Fp2_element()
ZP = Fp2_element()
XQ = Fp2_element()
ZQ = Fp2_element()
xPQ = Fp2_element()
zPQ = Fp2_element()
A24 = Fp2_element()

XP = fp2_random_init(XP)
ZP = fp2_random_init(ZP)
XQ = fp2_random_init(XQ)
ZQ = fp2_random_init(ZQ)
xPQ = fp2_random_init(xPQ)
zPQ = fp2_random_init(zPQ)
A24 = fp2_random_init(A24)

 
 
fp2_write_to_file(XP, n, "mem_XP_0.txt", "mem_XP_1.txt")
fp2_write_to_file(ZP, n, "mem_ZP_0.txt", "mem_ZP_1.txt")
fp2_write_to_file(XQ, n, "mem_XQ_0.txt", "mem_XQ_1.txt")
fp2_write_to_file(ZQ, n, "mem_ZQ_0.txt", "mem_ZQ_1.txt")
fp2_write_to_file(xPQ, n, "mem_xPQ_0.txt", "mem_xPQ_1.txt")
fp2_write_to_file(zPQ, n, "mem_zPQ_0.txt", "mem_zPQ_1.txt")
fp2_write_to_file(A24, n, "mem_A24_0.txt", "mem_A24_1.txt") 

# check if the hw-friendly sage function fits to the software one

(a0,a1,a2,a3,a4,a5) = xDBLADD_loop(XP,ZP,XQ,ZQ,xPQ,zPQ,A24,start_index,end_index,sk) 
(a0,a1,a2,a3,a4,a5) = xDBLADD_loop(a0,a1,a2,a3,a4,a5,A24,start_index,end_index,sk)
(a0,a1,a2,a3,a4,a5) = xDBLADD_loop(a0,a1,a2,a3,a4,a5,A24,start_index,end_index,sk)

(b0,b1,b2,b3,b4,b5) = xDBLADD_hw_loop(XP,ZP,XQ,ZQ,xPQ,zPQ,A24,start_index,end_index,sk)
(b0,b1,b2,b3,b4,b5) = xDBLADD_hw_loop(b0,b1,b2,b3,b4,b5,A24,start_index,end_index,sk)
(b0,b1,b2,b3,b4,b5) = xDBLADD_hw_loop(b0,b1,b2,b3,b4,b5,A24,start_index,end_index,sk)

assert((a0.r, a0.i) == (b0.r, b0.i))
assert((a1.r, a1.i) == (b1.r, b1.i))
assert((a2.r, a2.i) == (b2.r, b2.i))
assert((a3.r, a3.i) == (b3.r, b3.i))
assert((a4.r, a4.i) == (b4.r, b4.i))
assert((a5.r, a5.i) == (b5.r, b5.i))

(XP,ZP,XQ,ZQ,xPQ,zPQ) = xDBLADD_hw_loop(XP,ZP,XQ,ZQ,xPQ,zPQ,A24,start_index,end_index,sk)
(XP,ZP,XQ,ZQ,xPQ,zPQ) = xDBLADD_hw_loop(XP,ZP,XQ,ZQ,xPQ,zPQ,A24,start_index,end_index,sk)
(XP,ZP,XQ,ZQ,xPQ,zPQ) = xDBLADD_hw_loop(XP,ZP,XQ,ZQ,xPQ,zPQ,A24,start_index,end_index,sk)

fp2_write_to_file(XP, n, "sage_XP_0.txt", "sage_XP_1.txt") 
fp2_write_to_file(ZP, n, "sage_ZP_0.txt", "sage_ZP_1.txt")
fp2_write_to_file(XQ, n, "sage_XQ_0.txt", "sage_XQ_1.txt") 
fp2_write_to_file(ZQ, n, "sage_ZQ_0.txt", "sage_ZQ_1.txt")
fp2_write_to_file(xPQ, n, "sage_xPQ_0.txt", "sage_xPQ_1.txt") 
fp2_write_to_file(zPQ, n, "sage_zPQ_0.txt", "sage_zPQ_1.txt")




