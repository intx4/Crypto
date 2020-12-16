from sage.all import *
#from pylsfr import LSFR #couldn't pip install this
from sage.matrix.berlekamp_massey import berlekamp_massey as bm
from Crypto.Util.Padding import pad
from Crypto.Cipher import AES
from Crypto.Util.strxor import strxor
from binascii import unhexlify
from sage.crypto.lfsr import lfsr_sequence
#load("./25-parameters.py")
load("./12345-params.py")

ct = Q3a_y
key = Q3a_k
block_size = 16 #when we use 2*block_size is because we are in the hex representation (that is twice the len )

#building Z used in encrypt2
h = pad(b'\x11',128)
x = h + bytes.fromhex('A'*32)
x = x.hex().encode()
z = pad(x,16)
#print(z)
Z = []
for i in range(0,len(z), block_size):
    Z.append(z[i:i+block_size])
#print(Z,len(Z))

ct_blocks = []
for i in range(0,len(ct), 2*block_size):
    block = ct[i:i+2*block_size]
    t = (i // (2*block_size), block)
    ct_blocks.append(t)
#print(ct_blocks)

#build keys
dictionary = 'abcdef0123456789'
"""
cand_keys = []
pos = []
for i,c in enumerate(list(key)):
    if c == '?':
        pos.append(i)
key = list(key)
for d in dictionary:
    key[pos[0]] = d
    for d_ in dictionary:
        key[pos[1]] = d_
        cand_keys.append("".join(key))
final_pos = 18 #last block of round 1 in the ct
#treat each char of k as 1 byte not hex representation
k1_corr_pos = 5 #from 0
k2_corr_pos = 10 #from 16=0
j = 0
final_blocks = []
for b in ct_blocks:
    if b[0] == final_pos + j*19:
        j += 1
        c = list(b[1])
        corr_index = -1
        corr_pos_in_block = []
        i = 0
        for i in range(0,len(c)):
            if i % 2 == 0:
                corr_index += 1
            if c[i] == '?':
                corr_pos_in_block.append(corr_index)
        if k1_corr_pos not in corr_pos_in_block and k2_corr_pos not in corr_pos_in_block: #we don't want overlap in the corruption of key and cipher
            t = (b, corr_pos_in_block)
            final_blocks.append(t)
print(final_blocks)
all_tests = []
for j in range(0,len(final_blocks)):
    test_blocks = []
    pos = []
    test_block = final_blocks[j][0][1]
    for i,c in enumerate(list(test_block)):
        if c == '?':
            pos.append(i)
    tb = list(test_block)
    for d in dictionary:
        tb[pos[0]] = d
        for d_ in dictionary:
            tb[pos[1]] = d_
            test_blocks.append("".join(tb))
    all_tests.append(test_blocks)
key = []
rec_f_blocks = []

for k in cand_keys:

    k1 = k[0:16].encode()
    k2 = k[16:32].encode()
    aes = AES.new(bytes.fromhex(k), AES.MODE_ECB)

    for j in range(0,len(all_tests)):
        target = ct_blocks[final_blocks[j][0][0]-1][1] #before the last one of the round
        for test_block in all_tests[j]:
            a = strxor(k2,bytes.fromhex(test_block))
            c = aes.decrypt(a)
            c36 = strxor(c,Z[18]) #pad
            y36 = strxor(c36,k1)
            y36 = y36.hex()
            y36 = list(y36)
            target = list(target)

            ok = True
            for i in range(0,len(target)):
                corr_pos = final_blocks[j][1]
                if i not in corr_pos:
                    if y36[i] != target[i] and target[i] != '?':
                        ok = False
                        break
            if ok == True:
                key.append(k)
                rec_f_blocks.append(test_block)
                print('possible key: ', k, k == "45729a026cf8f6d1cdbb40d3e77887cd") #for test
"""
#key = "ed0242ed070ef2d72a20ecd71135ed03" #Personal Params
key = "45729a026cf8f6d1cdbb40d3e77887cd"
i_ct = []
k1 = key[0:16].encode()
k2 = key[16:32].encode()
aes = AES.new(bytes.fromhex(key), AES.MODE_ECB)
Z[16] = k1
Z[17] = k2
#build All final blocks
rec_f_blocks = []
all_tests = []
#build all possible final blocks
for j in range(18,len(ct_blocks),19):
    final = ct_blocks[j][1]
    test_blocks = []
    pos = []
    for i,c in enumerate(list(final)):
        if c == '?':
            pos.append(i)
    tb = list(final)
    for d in dictionary:
        tb[pos[0]] = d
        for d_ in dictionary:
            tb[pos[1]] = d_
            test_blocks.append("".join(tb))
    all_tests.append(test_blocks)
#find the right one
k = 0
for j in range(17,len(ct_blocks),19):
    target = ct_blocks[j][1]
    for test_block in all_tests[k]:
        a = strxor(k2,bytes.fromhex(test_block))
        c = aes.decrypt(a)
        c36 = strxor(c,Z[18]) #pad
        y36 = strxor(c36,k1)
        y36 = y36.hex()
        y36 = list(y36)
        target = list(target)

        ok = True
        for i in range(0,len(target)):
            if y36[i] != target[i] and target[i] != '?':
                ok = False
                break
        if ok == True:
            rec_f_blocks.append(test_block)
            k += 1
            break
#print('Recovered final blocks: ', rec_f_blocks)
j = 0
for lastb in rec_f_blocks:
    c = strxor(bytes.fromhex(lastb),Z[17])
    for i in range(18,0,-1):
        b = aes.decrypt(c)
        c = strxor(b,Z[i])
    up = strxor(bytes.fromhex(ct_blocks[j][1]), c)
    c = aes.decrypt(c)
    uc = strxor(Z[0],c)
    i_ct.append(uc.decode()+up.decode())
    j += 19
i_ct = ''.join(i_ct)[:-6] #remove pad
print(i_ct)


######################################### PART B ####################################

header = '4E414E49213F0D0A'
sol = "Will you choose that ticket and live on as a man? Or will you choose this one and go back to being a woman? No matter what you choose, I'm sure you will continue to waver. But what's wrong with that? Manly? Womanly? Are those random values that others made up really what you were striving toward? If things were so clear cut, then neither men, women, you, or me would be leading such painful lives (by Gintoki Sakata, Gintama' TV 2012)."
header = bytes.fromhex(header)
y = bytes.fromhex(i_ct)
h = y[:len(header)]
first_bytes = strxor(h,header)
print(first_bytes)
hex_exp = first_bytes.hex()
first_bits = bin(int(hex_exp,16))[2:]
print(first_bits)
#print(bytes.fromhex(strxor(h,bytes.fromhex(hex_exp)).hex()))
S = []
for b in first_bits:
    S.append(int(b))
print(S,len(S))
state = S[-16:]
T = list(map(GF(2),S))
g = bm(T)
f = g.reverse()
C = companion_matrix(f)
while len(S) < 4*len(i_ct):
    S.append((vector(state)*C)[0])
    state = S[-16:]
    j += 1
S = [str(s) for s in S]
bin_repr = ''.join(S)
mu = int(bin_repr,2)
print(mu)
mu = hex(mu)[2:len(i_ct)+2]

x = strxor(bytes.fromhex(i_ct), bytes.fromhex(mu))
print(x.decode())
