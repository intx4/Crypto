from sage.all import *
from sage.misc.prandom import randrange
load("./25-parameters.py")
#load("./12345-params.py")
import math

def find_small_factors(v,B):
    F = factor(v)
    small_factors = []
    eps = 1
    while eps < B:
        for fact in F:
            f = fact[0]
            mult = fact[1]
            if f < B:
                eps *= (f**mult)
                print(eps,' / ', B)
                small_factors.append(fact)
    return small_factors

def ph(P,Q,sf):
    """
    The idea is the following: we will use Pohlig Hellman applied only to the small factors. By doing this, in the end we
    will find k mod(prod[small_factors]) but this product is larger than B (see find_small_factors). We know that the e we are looking for is less than B, so
    we will find the correct solution anyway
    """
    moduli = []
    remainders = []
    for i in sf:
        P0 = P* ZZ(P.order()/i[0])
        Q0 = Q* ZZ(P.order()/i[0])
        moduli.append(i[0])
        remainders.append(discrete_log(Q0,P0,i[0],operation = '+'))
    return CRT_list(remainders,moduli)

def lsb(x,w):
    return x & ((1 << w) -1)

def seed(sigma,w,n,f):
    sigmas = []
    sigmas.append(sigma)
    for i in range(1,n):
        z = f * ((sigmas[i-1]).__xor__(( sigmas[i-1]>>(w-2) ))) + i
        s = lsb(z,w)
        sigmas.append(s)
    return n,sigmas

def next(State,C):
    n = State[0]
    if n >= C['n']:
        if n > C['n']:
            print('The generator was never seeded')
            return
        State = twist(State,C)
    n = State[0]
    sigmas = State[1]
    y_p = sigmas[n]
    y_p = y_p^^((y_p >> C['u']) & C['d'])
    y_p = y_p^^((y_p << C['s']) & C['b'])
    y_p = y_p^^((y_p << C['t']) & C['c'])
    y_p = y_p^^(y_p >> C['l'])
    n += 1
    State_p = (n,sigmas)
    y = lsb(y_p,C['w'])
    return State_p,y

def twist(State,C):
    sigmas = State[1]
    mu_L = (1 << C['r'])-1
    mu_L = int(mu_L) #DO NOT CHANGE
    mu_U = lsb(~mu_L,C['w'])
    for i in range(0,C['n']):
        x = (sigmas[i] & mu_U) + (sigmas[(i+1) % C['n']] & mu_L)
        z = x >> 1
        if x % 2 == 1:
            z = z^^(C['a'])
        sigmas[i] = (sigmas[(i+C['m'])%C['n']])^^(z)
    return 0,sigmas

def random(C,sigma,R):
    State = seed(sigma,C['w'],C['n'],C['f'])
    y = 0
    for i in range(1,R+1):
        State_p, y_p = next(State,C)
        State = State_p
        y = y_p
    return y

#PART A
p = Q2a_p
a = Q2a_a
b = Q2a_b
n = Q2a_n
P = Q2a_P
Q = Q2a_Q

C = Q2a_C
R = Q2a_R

B = 2**32
small_factors = find_small_factors(n,B)
#print(small_factors)
E = EllipticCurve([GF(p)(0),0,0,a,b])
P = E(P[0],P[1])
Q = E(Q[0],Q[1])
print('Starting Pohlig Hellman')
e = ph(P,Q,small_factors)
print(e, e > 2**31, e < 2**32)
print(random(C,e,R))

#PART B
"""
Very difficult to untemper: to understand the code, it's crucial to draw same diagrams to understand what's going on
"""
def unshiftRightL(x, l):
    i = 1
    while i*l < 128:
        x = x^^(x >> i*l)
        i+=1
    return x

def unshiftLeft(x, shift, mask):
    i = 1
    m = (1 << shift) -1
    while i * shift < 128:
        partmask = mask & (m << (shift * i))
        x = x^^((x << shift) & partmask)
        i += 1
    return x

def unshiftRightU(x, u, d):
    i = 1
    m = (1 << u) -1
    m = m << (128 - u)
    while i * u < 128:
        partmask = d & (m >> (u * i))
        x = x^^((x >> u) & partmask)
        i += 1
    return x
def untemper(y,C):
        v0 = y
        v1 = unshiftRightL(v0, C['l'])
        v2 = unshiftLeft(v1,C['t'],C['c'])
        v3 = unshiftLeft(v2,C['s'],C['b'])
        v4 = unshiftRightU(v3,C['u'],C['d'])

        a = v4
        a = a^^((a >> C['u']) & C['d'])
        #print(a==v3)
        a = a^^((a << C['s']) & C['b'])
        #print(a==v2)
        a = a^^((a << C['t']) & C['c'])
        #print(a==v1)
        a = a^^(a >> C['l'])
        #print(a==v0)
        a = lsb(a,C['w'])

        return v4, a==y

C = Q2b_C
randoms = Q2b_out
sigmas = []

for i in range(0,C['n']):
    v,check = (untemper(randoms[i],C))
    sigmas.append(int(v))
State = (C['n'], sigmas)

for i in range(C['n'],len(randoms)):
    State,y = next(State,C)
    #print(y == randoms[i])

State,pred = next(State,C)
print('Predicted: ', pred)
