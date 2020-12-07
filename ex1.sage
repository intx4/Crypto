from sage.all import *
from sage.misc.prandom import randrange
load("./25-parameters.py")
#load("./12345-params.py")
import hashlib

def setup():
    p = Q1_p
    q = Q1_q
    g = Q1_g
    Zq = Zmod(q)
    Zq_star = Zq.unit_group()
    t = Zq_star.random_element().value()
    h = Integer(g).powermod(t,p)
    return (p,g,q,h)

def commit(p,g,q,h,x,r):
    Zq = Zmod(q)
    Zq_star = Zq.unit_group()
    r = Zq_star.random_element().value()
    a = Integer(g).powermod(x,p)
    b = Integer(h).powermod(r,p)
    return ((a*b)%p)

def open(p,g,h,c,v):
    x_p = v[0]
    r_p = v[1]
    a = Integer(g).powermod(x_p,p)
    b = Integer(h).powermod(r_p,p)
    c_p = (a*b)%p
    if c == c_p:
        return x_p
    else:
        return -1
#PART A
def find_h(g,p,q,c,x,r):
    a = power_mod(Integer(g),x,p)
    i = Integer(a).inverse_mod(p)
    grt = (i*c)%p #g^rt mod p
    i = Integer(r).inverse_mod(q) #r is in Zqstar
    h = power_mod(Integer(grt),i,p)
    return h%p

p,g,q,h = setup()
#print(find_h(g,p,q,Q1a_c,Q1a_x,Q1a_r))

#PART B
def forge(g,p,q,tau,x0,x1,r0,c):
    i = Integer(tau).inverse_mod(q)
    rf = (x0-x1+tau*r0)*i
    return rf%q

#print(forge(g,p,q,Q1b_tau,Q1b_x_0,Q1b_x_1,Q1b_r,Q1b_c))

#PART C

def Floyd(x0,k):
    a = x0
    b = x0
    b = hashlib.sha256((k+str(b)).encode()).digest()[:5]
    b = int.from_bytes(b,"big")
    start = True
    
    while a != b:
        a = hashlib.sha256((k+str(a)).encode()).digest()[:5]
        a = int.from_bytes(a,"big")
        if start == True:
            b = hashlib.sha256((k+str(b)).encode()).digest()[:5]
            b = int.from_bytes(b,"big")
            start = False
        else:
            b = hashlib.sha256((k+str(b)).encode()).digest()[:5]
            b = int.from_bytes(b,"big")
            b = hashlib.sha256((k+str(b)).encode()).digest()[:5]
            b = int.from_bytes(b,"big")
    a = x0
    while a != b:
        a_old = a
        b_old = b
        a = hashlib.sha256((k+str(a)).encode()).digest()[:5]
        a = int.from_bytes(a,"big")
        b = hashlib.sha256((k+str(b)).encode()).digest()[:5]
        b = int.from_bytes(b,"big")
    return a_old,b_old

#Initialization
x0 = Q1c_x_0
h = Q1c_h
c = Q1c_c
r0 = Q1c_r_0
k = Q1c_hash_key

collisions = Floyd(Q1c_x_start,k)
if collisions[0] == x0:
    x1 = collisions[1]
else:
    x1 = collision[0]
rf = x0+r0-x1
print(x1,rf%q)
