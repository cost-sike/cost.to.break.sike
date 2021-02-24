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
args = parser.parse_args()

if args.seed:
  set_random_seed(args.seed)
  random.seed(args.seed)

# radix, can be 8, 16, 32, 64, etc, need to be careful about overflow 
w=args.w 
prime=args.prime
R=2^(args.R) 

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

 
def get_4_isog(X4,Z4):
  t0 = Fp2_element()
  t1 = Fp2_element()
  t2 = Fp2_element()
  t3 = Fp2_element()
  t4 = Fp2_element()
  t0 = fp2_add(X4, Z4)
  t1 = fp2_sub(X4, Z4)
  t2 = fp2_mult(X4, X4)           
  t3 = fp2_mult(Z4, Z4)           
  t4 = fp2_add(t3, t3)
  t3 = fp2_add(t2, t2)
  t2 = fp2_mult(t3, t3)          
  t5 = fp2_mult(t4, t4)         
  t3 = fp2_add(t4, t4)
  return t2,t5,t3,t1,t0
 
def get_4_isog_hw(X4,Z4):
  t0 = Fp2_element()
  t1 = Fp2_element()
  t2 = Fp2_element()
  t3 = Fp2_element()
  t4 = Fp2_element() 
  t5 = Fp2_element()

  t0 = fp2_add(X4, Z4)
  t1 = fp2_sub(X4, Z4) 

  t4 = t0   
  t5 = t1     
  t2 = fp2_mult(X4, X4)
  t3 = fp2_mult(Z4, Z4)       
   
  t0 = fp2_add(t3, t3)
  t1 = fp2_add(t2, t2) 

  t2 = fp2_mult(t1, t1)
  t3 = fp2_mult(t0, t0)         

  t1 = fp2_add(t0, t0)

  return t2,t3,t1,t5,t4

def eval_4_isog(X,ZZ,C0,C1,C2):
  t0 = Fp2_element()
  t1 = Fp2_element()
  t2 = Fp2_element()
  t3 = Fp2_element()
  t4 = Fp2_element()
  t5 = Fp2_element()
  t6 = Fp2_element()
  t0 = fp2_add(X, ZZ)
  t1 = fp2_sub(X, ZZ)
  t2 = fp2_mult(C0, t0)           
  t3 = fp2_mult(C1, t0)         
  t0 = fp2_mult(C2, t1)          
  t5 = fp2_mult(t1, t2)         
  t4 = fp2_add(t0, t3)
  t6 = fp2_sub(t0, t3) 
  t2 = fp2_mult(t4, t4)           
  t3 = fp2_mult(t6, t6)          
  t1 = fp2_add(t2, t5)
  t0 = fp2_sub(t3, t5)
  t4 = fp2_mult(t1, t2)       
  t5 = fp2_mult(t0, t3)                   
  return t4,t5


def eval_4_isog_hw(X,ZZ,C0,C1,C2):
  t0 = Fp2_element()
  t1 = Fp2_element()
  t2 = Fp2_element()
  t3 = Fp2_element()
  t4 = Fp2_element()
  t5 = Fp2_element()
  t6 = Fp2_element()

  t0 = fp2_add(X, ZZ)
  t1 = fp2_sub(X, ZZ) 

  t2 = fp2_mult(t0, C0)
  t3 = fp2_mult(t0, C1)

  t4 = t2
  t5 = t3 
  
  t2 = fp2_mult(t1, t4)
  t3 = fp2_mult(t1, C2)
    
  t4 = t2 
  t0 = fp2_add(t3, t5)
  t1 = fp2_sub(t3, t5) 

  t2 = fp2_mult(t0, t0)
  t3 = fp2_mult(t1, t1)

  t6 = t2
  t5 = t3 
  t0 = fp2_add(t2, t4)
  t1 = fp2_sub(t3, t4)

  t2 = fp2_mult(t0, t6)
  t3 = fp2_mult(t1, t5)

  return t2,t3


def fp2_write_to_file(a, n, FILE_NAME_0, FILE_NAME_1):
  fp0 = open(FILE_NAME_0, "w")
  fp1 = open(FILE_NAME_1, "w")
  a0 = a.r
  a1 = a.i
  oa0 = [Z(0)]*n
  oa1 = [Z(0)]*n
  for i in range(n):
    oa0[i] = Z((Z(a0) >> (w*i)) % 2^w)
    fp0.write(format_element.format(oa0[i]))
    fp0.write("\n")
    oa1[i] = Z((Z(a1) >> (w*i)) % 2^w)
    fp1.write(format_element.format(oa1[i]))
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


# generate input for get_4_isog
X4 = Fp2_element()
Z4 = Fp2_element() 

X4 = fp2_random_init(X4)
Z4 = fp2_random_init(Z4) 
 
fp2_write_to_file(X4, n, "get_4_isog_mem_X4_0.txt", "get_4_isog_mem_X4_1.txt")
fp2_write_to_file(Z4, n, "get_4_isog_mem_Z4_0.txt", "get_4_isog_mem_Z4_1.txt")

# test pure software verion and hw-friendly version at the same time
(constant_1, constant_2, coeff_0, coeff_1, coeff_2) = get_4_isog(X4,Z4)
(cconstant_1, cconstant_2, ccoeff_0, ccoeff_1, ccoeff_2) = get_4_isog_hw(X4,Z4)

assert((constant_1.r, constant_1.i) == (cconstant_1.r, cconstant_1.i))
assert((constant_2.r, constant_2.i) == (cconstant_2.r, cconstant_2.i))
assert((coeff_0.r, coeff_0.i) == (ccoeff_0.r, ccoeff_0.i))
assert((coeff_1.r, coeff_1.i) == (ccoeff_1.r, ccoeff_1.i))
assert((coeff_2.r, coeff_2.i) == (ccoeff_2.r, ccoeff_2.i))

fp2_write_to_file(coeff_0, n, "get_4_isog_mem_coeff_0_0.txt", "get_4_isog_mem_coeff_0_1.txt")
fp2_write_to_file(coeff_1, n, "get_4_isog_mem_coeff_1_0.txt", "get_4_isog_mem_coeff_1_1.txt")
fp2_write_to_file(coeff_2, n, "get_4_isog_mem_coeff_2_0.txt", "get_4_isog_mem_coeff_2_1.txt")

for i in range(3):
  X = Fp2_element()
  ZZ = Fp2_element() 
  X = fp2_random_init(X4)
  ZZ = fp2_random_init(Z4)

  fp2_write_to_file(X, n, str(i)+"-sage_eval_4_isog_mem_X_0.txt", str(i)+"-sage_eval_4_isog_mem_X_1.txt")
  fp2_write_to_file(ZZ, n, str(i)+"-sage_eval_4_isog_mem_Z_0.txt", str(i)+"-sage_eval_4_isog_mem_Z_1.txt")

  (res_0, res_1) = eval_4_isog(X,ZZ,coeff_0,coeff_1,coeff_2)
  (rres_0, rres_1) = eval_4_isog_hw(X,ZZ,coeff_0,coeff_1,coeff_2)

  assert((res_0.r, res_0.i) == (rres_0.r, rres_0.i))
  assert((res_1.r, res_1.i) == (rres_1.r, rres_1.i))

  fp2_write_to_file(res_0, n, str(i)+"-sage_eval_4_isog_t10_0.txt", str(i)+"-sage_eval_4_isog_t10_1.txt")
  fp2_write_to_file(res_1, n, str(i)+"-sage_eval_4_isog_t11_0.txt", str(i)+"-sage_eval_4_isog_t11_1.txt")
 




