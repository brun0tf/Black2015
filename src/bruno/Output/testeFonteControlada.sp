
.include ptm_90nm.l
.param 'supply' = 1.2
+	'lambda' = 1.8087
+	'widthPmos' = '200n*lambda'
+	'iTotal' = 1.0065e-003
+	'iHold' = 4.8377e-004
+	'iPrompt' = (iTotal - iHold)
V1		VDD  		0		DC		supply
V2		VDD2  	0		DC		supply

vinA 	high	0	PWL(0ns 0		0.1ns	0			0.101ns	supply)
vinB 	low	0	PWL(0ns supply	0.1ns	supply	0.101ns	0)

vinC 	teste	0	PWL(0ns supply	3ns	supply	3.101ns	0)


.subckt inverter in out VDD GND 
MP1	VDD	in	out	VDD pmos	L = 90n  W = 'widthPmos'	
MN2	GND	in	out	GND nmos	L = 90n  W = 200n		
.ends inverter

.subckt AOI21 inA	inB	inC	out	VDD	GND
MP1	out	inB	pu_n1	VDD	pmos	L = 90n  W = 'widthPmos*2'
MP2	pu_n1	inC	out	VDD	pmos	L = 90n  W = 'widthPmos*2'
MP3	VDD	inA	pu_n1	VDD	pmos	L = 90n  W = 'widthPmos*2'
MN4	GND	inA	out	GND	nmos	L = 90n  W = 200n
MN5	GND	inC	pd_n1	GND	nmos	L = 90n  W = 2*200n
MN6	pd_n1	inB	out	GND	nmos	L = 90n  W = 2*200n
.ends AOI21


Xdut   high	high	high		outDUT	VDD	GND	AOI21

*linear = gname node1 node2 na1 nb1 K
*G1	VDD	outDUT	Xdut.pu_n1	0	2 

*n�o linear = gname node1 node2 [cur='expression'] [chg='expression'] [Options]
*G2	VDD	xdut.pu_n1 cur = exp


*iSp	Xdut.VDD	Xdut.out	0	exp	(0	'iPrompt'	2n	2p	2.015n	1p)
*iSh	Xdut.VDD	Xdut.out	0	exp	(0	'iHold'	2n	2p	2.1n	4p)

Xinv0	outDut	void	VDD	GND	inverter
Xinv1	outDut	void	VDD	GND	inverter
Xinv2	outDut	void	VDD	GND	inverter
Xinv3	outDut	void	VDD	GND	inverter


.measure	tran	vPeakMin	min	v(Xdut.out)	 from = 2.04ns to = 2.1ns
.measure	tran	vPeakMax	max	v(Xdut.out)	 from = 2.04ns to = 2.1ns

*.model 		 optmod opt level=1 itropt=40
*.optimize 	 opt2 model=optmod analysisname=tran
*.optgoal     opt2 VPeakMin = 1.2
*.paramlimits opt2 'iHold' minval=20u maxval=2m

*.measure tran avgPrompt			avg i(iSp) from = 2ns to = 2.4ns
*.measure tran cargaPrompt		param = 'avgPrompt * 0.4n'
*.measure tran avgHold			avg i(iSh) from = 2ns to = 2.4ns
*.measure tran cargaHold		param = 'avgHold * 0.4n'

.print v(outDUT) v(Xdut.pu_n1) 
.print i(iSh) i(g1) i(g2)

.tran	1p	5n
.end
