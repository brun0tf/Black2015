
.include ptm_90nm.l
.param 'supply' = 1.2
+	'lambda' = 1.8087
+	'widthPmos' = '200n*lambda'
+	'iTotal' = 6.1293e-004
*2.1856e-004
V1		VDD  		0		DC		supply
V2		VDD2  	0		DC		supply

vinA 	high	0	PWL(0ns 0		1ns	0			1.001ns	supply)
vinB 	low	0	PWL(0ns supply	1ns	supply	1.001ns	0)

.subckt inverter in out VDD GND 
MP1	VDD	in	out	VDD pmos	L = 90n  W = 'widthPmos'	
MN2	GND	in	out	GND nmos	L = 90n  W = 200n		
.ends inverter

.SUBCKT nand3 A B C out VDD GND
mp1 out a vdd vdd pmos  l = 90n w = 'widthpmos'
mp2 out b vdd vdd pmos  l = 90n w = 'widthpmos'
mp3 out c vdd vdd pmos  l = 90n w = 'widthpmos'
v1 pd_n1  nAux 0  
mn4 out a nAux gnd nmos  l = 90n w = 3*200n
mn5 pd_n1 b pd_n3 gnd nmos  l = 90n w = 3*200n
mn6 pd_n3 c gnd gnd nmos  l = 90n w = 3*200n
.ENDS nand3

Xdut   high	high	low		outDUT	VDD	GND	nand3

iSp	Xdut.pd_n1	Xdut.GND	0	exp	(0	'iTotal'	2n	2p	2.015n	0p)
fSh	Xdut.pd_n1	Xdut.GND poly(2) xdut.v1 vi2 0 0 0 0 -1


iSh_	y	GND	0	exp	(0	1	2.015n	0p	2.1n	4p)
vi2	y	GND	0

Xinv0	outDut	void	VDD	GND	inverter
Xinv1	outDut	void	VDD	GND	inverter
Xinv2	outDut	void	VDD	GND	inverter
Xinv3	outDut	void	VDD	GND	inverter



.measure	tran	setTracker	min	v(Xdut.pd_n1)	 from = 2.0ns to = 2.1ns


.measure	tran	vPeakMin	min	v(Xdut.pd_n1)	 from = 2.04ns to = 2.1ns

.measure	tran	vPeakMax	max	v(Xdut.pd_n1)	 from = 2.04ns to = 2.1ns


.measure tran avgPrompt			avg i(iSp) from = 2ns to = 2.4ns
.measure tran cargaPrompt		param = 'avgPrompt * 0.4n'
.measure tran avgHold			avg i(iSh) from = 2ns to = 2.4ns
.measure tran cargaHold		param = 'avgHold * 0.4n'

.print v(outDUT) v(Xdut.pd_n1)
.print i(fSh)

.tran	1p	5ns
.end
