
.include ptm_90nm.l
.param 'supply' = 1.2
+	'lambda' = 1.8087
+	'widthPmos' = '200n*lambda'
+	'iTotal' = 6.1337E-4
+	'Qcoll' = 15f - 8.6485E-15
+	'tF_delay' = 2n
+	'x' = 0p
+	'y' = 0p
V1		VDD  		0		DC		supply
V2		VDD2  	0		DC		supply

vinA 	high	0	PWL(0ns 0		1ns	0			1.001ns	supply)
vinB 	low	0	PWL(0ns supply	1ns	supply	1.001ns	0)

.subckt inverter in out VDD GND 
MP1	VDD	in	out	VDD pmos	L = 90n  W = 'widthPmos'	
MN2	GND	in	out	GND nmos	L = 90n  W = 200n		
.ends inverter

.subckt AOI21 inA	inB	inC	out	VDD	GND
mp3 pu_n1 ina vdd vdd pmos  l = 90n w = 'widthpmos*2'
v1 out  nAux 0  
mp1 nAux inb pu_n1 vdd pmos  l = 90n w = 'widthpmos*2'
mp2 pu_n1 inc nAux vdd pmos  l = 90n w = 'widthpmos*2'
mn6 pd_n1 inb out gnd nmos  l = 90n w = 2*200n
mn4 gnd ina out gnd nmos  l = 90n w = 200n
mn5 gnd inc pd_n1 gnd nmos  l = 90n w = 2*200n
.ends AOI21

Xdut   high	low	low		outDUT	VDD	GND	AOI21

iSp	Xdut.VDD	Xdut.pu_n1	0	exp	(0	'iTotal'	2n	2p	2.015n	1.06p)
fSh	Xdut.VDD	Xdut.pu_n1 poly(2) xdut.v1 vi2 0 0 0 0 1
iSh_	y	GND	0	exp	(0	1	2.015n	0p	2.1n	4p)
vi2	y	GND	0

Xinv0	outDut	void	VDD	GND	inverter
Xinv1	outDut	void	VDD	GND	inverter
Xinv2	outDut	void	VDD	GND	inverter
Xinv3	outDut	void	VDD	GND	inverter

.measure	tran	setTracker	max	v(Xdut.pu_n1)	 from = 2.0ns to = 2.1ns

.measure	tran	vPeakMin	min	v(Xdut.pu_n1)	 from = 2.04ns to = 2.1ns

.measure	tran	vPeakMax	max	v(Xdut.pu_n1)	 from = 2.04ns to = 2.1ns


.measure tran avgPrompt			avg i(iSp) from = 2ns to = 2.4ns
.measure tran cargaPrompt		param = 'avgPrompt * 0.4n'
.measure tran avgHold			avg i(fSh) from = 2ns to = 2.4ns
.measure tran cargaHold		param = 'avgHold * 0.4n'


.print v(outDUT) v(Xdut.pu_n1)
.print i(iSh) i(iSp)

.tran	1p	5ns
.end
