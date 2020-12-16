from pylfsr import LFSR
import itertools
import numpy as np
from Crypto.Util.strxor import strxor
from Crypto.Util.Padding import unpad
"""
Bruteforce extreme
"""
#i_ct = "941cccdb4f121b1506bb6c889c3cab560822614d361167ce9225d264f1a6a382758658e85a478f0339fe11059db451313bba368c050251819b5b9442b961008fac186d723290e430912ab23e33aacdafde9489188f39acc4fe4043de34f5fc3b013bcfddd772db4902ea133e6ca6ec74149f250493a107168f01a38adb6ffd37db3d2e8af0a926a8934c1125deb1fab5becb5e7a013cb59d1417a3dbfffc79f8c0122bdb744ae3c368c8e85a51e8dd0a4445d5cf69ac7c6201df0b77487ec6f700fb4927970ba2e391eec465e36297a253858682126c5dfa876cd204afe3e75f70220bc21fee07e56a2370223347e6371d441c6c260afa005b120eea5cb3bf621aa79f0b4b29ca4cbf582a4033d6a4a88554c3d8a2d3054a75883466023afb394d6c1c457d417b0958527c5a27cf65da20f9fd93e65d1a201076d3d1b648d3a9bd456396f1beffc7f369fb648cd61403f2cba30306fb2a1d9aa9949022842f00dfb515b050e58b4bc5cae17a16ec6661cd1027f5c642486e4763361adae17b063bc71ec774bc716935c5b0b3e8ed9b00b73794e4f24ef77d2cab2137de6efd9d950ef8b53a1089519bd6be4fbbaa89386bf513d020416f71423f575495"
i_ct = "c7f05e02786839c5dc835749dfd9d1e4f4cb115a7c0d5977d397d0aeea4058c63438bc047736482a2edb25674df524cde0e855cc4017666a92a890292d01bd6b3e6391a9ada014ded15e91d504438eaaee54b988987f22f6f5aaa2c81f6af4d6af5111a61134d80cb4b133d8ab09c588077309d361890a566b0a12d8e043abd6afd65858a1b9c4945671c82805fbfff6745bab7a9cedfbe75622b3aea38f1885813b0fc6d603b223e8fdd8ce6b5a6f9c607f850ab7864f181d8c9893bf511e635378ab152b5074cbd31fd748e6d0d216fa61f118e182324a6cb479d7698136e2e626a6578350018dfbfa120a1251a1f6710a63de120a916cfde5e77dc8f83316240c4cb3ce87b593c8d95ef8a154d6ee804f2c61d81e011b725b11b14fbc64728f24e7db2931fa51d1967f155fb8a7cd5d4a0a476c50119e4b49" 
len_x = len(bytes.fromhex(i_ct))
print(len_x)
#f_poly =  [1,2,3,5,6,7,10,11,15,16] #test params
f_poly = [1,2,6,9,10,11,15,16]
states = list(itertools.product([0,1], repeat=16))
states = [np.asarray(s) for s in states]
#personal
first_bits = [1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1]
#test
#first_bits = [1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1]
for j in range(0,20000):
	s = states[j]
	#s = [0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0]
	print ( j, '/',2**16)
	
	L = LFSR(fpoly = f_poly, initstate=s)
	S = L.runKCycle(4*2*len_x)
	S = S.astype(int).tolist()
	ok = True
	if S[0:len(first_bits)] != first_bits:
		continue
	#bin_repr = ['0','b']
	bin_repr = []
	for b in S:
		bin_repr.append(str(b))
	bin_repr = ''.join(bin_repr)
	mu = int(bin_repr,2)
	print(mu)
	mu = hex(mu)[2:2*len_x+2]
	print(len(mu))
	x = strxor(bytes.fromhex(i_ct), bytes.fromhex(mu))
	print(x)
	try:
		print(x.decode())
		break 
	except:
		break
