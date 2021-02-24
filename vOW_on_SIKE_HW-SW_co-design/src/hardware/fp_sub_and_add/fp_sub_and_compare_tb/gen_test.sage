# converted from Magma script

import sys
import argparse
import random 

parser = argparse.ArgumentParser(description='generate test inputs for subtraction unit/comparator.',
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
elif (prime == 434): 
    p = 2^216*3^137-1  
elif (prime == 503):
    p = 2^250*3^159-1 
elif (prime == 751):
    p = 2^372*3^239-1 

# Finite field
Fp = GF(p)
  
# number of digits in operands a and b
n = int(log(R,2)/w)

# force unsigned arithmetic
Z = IntegerRing()
Fr = IntegerModRing(R)
pp = Fr(-p^-1)
assert((pp % 2^w) == 1)

# generate random inputs in range [0, p]
#a = Fp.random_element()  
#b = Fp.random_element()  
a = Z(random.randint(0, p))
b = Z(random.randint(0, p))
#a = Z(random.randint(-p, 0))
#b = Z(p)

# move a, b to range [0, 2*p]
if (random.randint(0, 1) == 0):
  print "a is bigger than p"
  a += p
else:
  print "a is NOT bigger than p"

if (random.randint(0, 1) == 1):
  print "b is bigger than p"
  b += p
else:
  print "b is NOT bigger than p"

#print "p = ", p
#print "a = ", a
#print "b = ", b

# write digits in a and b into files
oa = [Z(0)]*n
ob = [Z(0)]*n

f_a = open("Sage_mem_a.txt", "w");
f_b = open("Sage_mem_b.txt", "w");

for i in range(n):  
    oa[i] = Z((Z(a) >> (w*i)) % 2^w)
    ob[i] = Z((Z(b) >> (w*i)) % 2^w)
    f_a.write(hex_format_element.format(oa[i]))
    f_a.write("\n")
    f_b.write(hex_format_element.format(ob[i]))
    f_b.write("\n")

f_a.close()
f_b.close()

# subtraction result of c
c = Z(a - b)

#print "c = ", c

# write digits in c into files
oc = [Z(0)]*n 

f_c = open("Sage_sub_res.txt", "w"); 

for i in range(n):  
    oc[i] = Z((Z(c) >> (w*i)) % 2^w) 
    f_c.write(hex_format_element.format(oc[i]))
    f_c.write("\n") 

f_c.close()  

# write value 0 to a file
t = Z(0)

ot = [Z(0)]*n 

f_t = open("zero.mem", "w"); 

for i in range(n):  
    ot[i] = Z((Z(t) >> (w*i)) % 2^w) 
    f_t.write(format_element.format(ot[i]))
    f_t.write("\n") 

f_t.close()  

# print comparison result
f_d = open("Sage_comp_res.txt", "w"); 

if (c > 0):
  print "\nSage comparison result: (a-b) is bigger than 0."
  f_d.write("(a-b) is bigger than 0.")
  f_d.write("\n")
else:
  print "\nSage comparison result: (a-b) is NOT bigger than 0."
  f_d.write("(a-b) is NOT bigger than 0.")
  f_d.write("\n")

f_d.close()  
