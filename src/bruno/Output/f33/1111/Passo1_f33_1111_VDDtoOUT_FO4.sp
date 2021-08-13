
.include ptm_90nm.l
.param 'supply' = 1.2
+	'lambda' = 1.8087
+	'widthPmos' = '200n*lambda'
+	 'iTotal'  = 20u
V1		VDD  		0		DC		supply
V2		VDD2  	0		DC		supply
vinA 	high	0	PWL(0ns 0		1ns		0		1.001ns	supply)
vinB 	low		0	PWL(0ns supply	1ns		supply	1.001ns	0)

.subckt inverter in out VDD GND 
MP1	VDD	in	out	VDD pmos	L = 90n  W = 'widthPmos'	
MN2	GND	in	out	GND nmos	L = 90n  W = 200n		
.ends inverter

.SUBCKT f33 a b c d out VDD GND
MP1 out a pu_n1 VDD pmos		L = 90n  W = 4*'widthPmos'
MP2 pu_n1 not_b pu_n3 VDD pmos	L = 90n  W = 4*'widthPmos'
MP3 pu_n3 c pu_n4 VDD pmos		L = 90n  W = 4*'widthPmos'
MP4 pu_n4 not_d VDD VDD pmos	L = 90n  W = 4*'widthPmos'
MP5 pu_n3 not_c pu_n6 VDD pmos	L = 90n  W = 4*'widthPmos'
MP6 pu_n6 d VDD VDD pmos		L = 90n  W = 4*'widthPmos'
MP7 pu_n1 b pu_n7 VDD pmos		L = 90n  W = 4*'widthPmos'
MP8 pu_n7 c pu_n8 VDD pmos		L = 90n  W = 4*'widthPmos'
MP9 pu_n8 d VDD VDD pmos		L = 90n  W = 4*'widthPmos'
MP10 pu_n7 not_c pu_n9 VDD pmos	L = 90n  W = 4*'widthPmos'
MP11 pu_n9 not_d VDD VDD pmos	L = 90n  W = 4*'widthPmos'
MN12 out not_b pd_n1 GND nmos	L = 90n  W = 3*200n
MN13 pd_n1 not_c pd_n3 GND nmos	L = 90n  W = 3*200n
MN14 pd_n3 d GND GND nmos		L = 90n  W = 3*200n
MN15 pd_n1 c pd_n5 GND nmos		L = 90n  W = 3*200n
MN16 pd_n5 not_d GND GND nmos	L = 90n  W = 3*200n
MN17 out a GND GND nmos			L = 90n  W = 1*200n
MN18 out b pd_n6 GND nmos		L = 90n  W = 3*200n
MN19 pd_n6 not_c pd_n7 GND nmos	L = 90n  W = 3*200n
MN20 pd_n7 not_d GND GND nmos	L = 90n  W = 3*200n
MN21 pd_n6 c pd_n8 GND nmos		L = 90n  W = 3*200n
MN22 pd_n8 d GND GND nmos		L = 90n  W = 3*200n
MP_inv23 not_b b VDD VDD pmos	L = 90n  W = 'widthPmos'
MN_inv24 not_b b GND GND nmos	L = 90n  W = 200n
MP_inv25 not_c c VDD VDD pmos	L = 90n  W = 'widthPmos'
MN_inv26 not_c c GND GND nmos	L = 90n  W = 200n
MP_inv27 not_d d VDD VDD pmos	L = 90n  W = 'widthPmos'
MN_inv28 not_d d GND GND nmos	L = 90n  W = 200n
.ENDS f33


Xdut	high	high	high	high		outDUT	VDD	GND	f33
iS	Xdut.VDD	Xdut.out	0	exp	(0	'iTotal'	2n	2p	2.015n	4p)

Xinv0	outDut	void	VDD	GND	inverter
Xinv1	outDut	void	VDD	GND	inverter
Xinv2	outDut	void	VDD	GND	inverter
Xinv3	outDut	void	VDD	GND	inverter

.measure	tran	Vpeak	max	v(Xdut.out)	 from = 1.5ns to = 3ns

.model	optmod	opt	itropt = 40
.optimize	opt2	model=optmod	analysisname=tran
.optgoal	opt2	vPeak = 1.2
.paramlimits opt2 'iTotal' minval=20u maxval=2m

.measure tran avgiS			avg i(iS) from = 2ns to = 2.4ns
.measure tran cargaTotal	param = 'avgiS * 0.4n'
.print v(outDUT)

.tran	1p	5ns
.end
