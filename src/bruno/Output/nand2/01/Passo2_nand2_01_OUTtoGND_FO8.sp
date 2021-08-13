
.include ptm_90nm.l
.param 'supply' = 1.2
+	'lambda' = 1.8087
+	'widthPmos' = '200n*lambda'
+	'iTotal' = 9.4673E-4
+	'iHold' = 20u
+	'iPrompt' = (iTotal - iHold)
V1		VDD  		0		DC		supply
V2		VDD2  	0		DC		supply

vinA 	high	0	PWL(0ns 0		1ns	0			1.001ns	supply)
vinB 	low	0	PWL(0ns supply	1ns	supply	1.001ns	0)

.subckt inverter in out VDD GND 
MP1	VDD	in	out	VDD pmos	L = 90n  W = 'widthPmos'	
MN2	GND	in	out	GND nmos	L = 90n  W = 200n		
.ends inverter

.SUBCKT nand2 a b out VDD GND
*.PININFO a:I b:I out:O VDD:P GND:G
*.EQN out=(!a + !b);
MP1 out a VDD VDD pmos		 L = 90n  W = 'widthPmos'
MP2 out b VDD VDD pmos		 L = 90n  W = 'widthPmos'
MN3 pd_n1 a GND GND nmos	 L = 90n  W = 2*200n
MN4 out b pd_n1 GND nmos	 L = 90n  W = 2*200n
.ENDS nand2

Xdut   low	high		outDUT	VDD	GND	nand2
iSp	Xdut.out	Xdut.GND	0	exp	(0	'iPrompt'	2n	2p	2.015n	4p)
iSh	Xdut.out	Xdut.GND	0	exp	(0	'iHold'	2n	2p	2.1n	4p)
Xinv0	outDut	void	VDD	GND	inverter
Xinv1	outDut	void	VDD	GND	inverter
Xinv2	outDut	void	VDD	GND	inverter
Xinv3	outDut	void	VDD	GND	inverter
Xinv4	outDut	void	VDD	GND	inverter
Xinv5	outDut	void	VDD	GND	inverter
Xinv6	outDut	void	VDD	GND	inverter
Xinv7	outDut	void	VDD	GND	inverter

.measure	tran	setTracker	min	v(Xdut.out)	 from = 2.0ns to = 2.1ns


.measure	tran	vPeakMin	min	v(Xdut.out)	 from = 2.04ns to = 2.1ns

.measure	tran	vPeakMax	max	v(Xdut.out)	 from = 2.04ns to = 2.1ns

.model 		 optmod opt level=1 itropt=40
.optimize 	 opt2 model=optmod analysisname=tran
.optgoal     opt2 VPeakMax = 0.0
.paramlimits opt2 'iHold' minval=20u maxval=2m

.measure tran avgPrompt			avg i(iSp) from = 2ns to = 2.4ns
.measure tran cargaPrompt		param = 'avgPrompt * 0.4n'
.measure tran avgHold			avg i(iSh) from = 2ns to = 2.4ns
.measure tran cargaHold		param = 'avgHold * 0.4n'

.print v(outDUT) v(Xdut.out)
.print i(iSh) i(iSp)

.tran	1p	5ns
.end
