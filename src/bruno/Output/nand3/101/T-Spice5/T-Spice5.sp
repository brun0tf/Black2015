
.include ptm_90nm.l
.param 'supply' = 1.2
+	'lambda' = 1.8087
+	'widthPmos' = '200n*lambda'
+	'iTotal' = 5.9083e-004
+	'iHold' = 20u
+	'iPrompt' = (iTotal - iHold)
+	'tF_delay' = 2n
V1		VDD  		0		DC		supply
V2		VDD2  	0		DC		supply

vinA 	high	0	PWL(0ns 0		1ns	0			1.001ns	supply)
vinB 	low	0	PWL(0ns supply	1ns	supply	1.001ns	0)

.subckt inverter in out VDD GND 
MP1	VDD	in	out	VDD pmos	L = 90n  W = 'widthPmos'	
MN2	GND	in	out	GND nmos	L = 90n  W = 200n		
.ends inverter

.SUBCKT nand3 A B C out VDD GND
MP1 out   A VDD   VDD   pmos	L = 90n  W = 'widthPmos'
MP2 out   B VDD   VDD   pmos	L = 90n  W = 'widthPmos'
MP3 out   C VDD   VDD 	pmos	L = 90n  W = 'widthPmos'
MN4 out   A x GND 	nmos	L = 90n  W = 3*200n
vi1 x	pd_n1	0 
MN5 pd_n1 B pd_n3 GND   nmos    L = 90n  W = 3*200n
MN6 pd_n3 C GND   GND 	nmos	L = 90n  W = 3*200n
.ENDS nand3

Xdut   high	low	high		outDUT	VDD	GND	nand3

iSp	Xdut.pd_n1	Xdut.GND	0	exp	(0	'iTotal'	2n	2p	2.015n	0p)
fSh	Xdut.pd_n1	Xdut.GND poly(2) xdut.vi1 vi2 0 0 0 0 -1


iSh_	y	GND	0	exp	(0	1	2.015n	0p	'tF_delay'	4p)
vi2	y	GND	0

Xinv0	outDut	void	VDD	GND	inverter
Xinv1	outDut	void	VDD	GND	inverter
Xinv2	outDut	void	VDD	GND	inverter
Xinv3	outDut	void	VDD	GND	inverter
Xinv4	outDut	void	VDD	GND	inverter
Xinv5	outDut	void	VDD	GND	inverter
Xinv6	outDut	void	VDD	GND	inverter
Xinv7	outDut	void	VDD	GND	inverter


.measure	tran	setTracker	min	v(Xdut.pd_n1)	 from = 2.0ns to = 2.1ns


.measure	tran	vPeakMin	min	v(Xdut.pd_n1)	 from = 2.04ns to = 2.1ns

.measure	tran	vPeakMax	max	v(Xdut.pd_n1)	 from = 2.04ns to = 2.1ns


.measure tran avgPrompt			avg i(iSp) from = 2ns to = 2.4ns
.measure tran cargaPrompt		param = 'avgPrompt * 0.4n'


.measure tran avgHold			avg i(fSh) from = 2ns to = 2.4ns
.measure tran cargaHold		param = 'avgHold * 0.4n'


.model 		 optmod opt level=1 itropt=40
.optimize 	 opt2 model=optmod analysisname=tran
.optgoal     opt2 cargaHold = 25f
.paramlimits opt2 'tF_delay' minval=2n maxval=3n


.print v(outDUT) v(Xdut.pd_n1)
.print i(fSh) i(iSp)

.tran	1p	5ns
.end
