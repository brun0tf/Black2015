
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

.SUBCKT nand3 A B C out VDD GND
v1 out  nAux 0  
mp1 nAux a vdd vdd pmos  l = 90n w = 'widthpmos'
mp2 nAux b vdd vdd pmos  l = 90n w = 'widthpmos'
mp3 nAux c vdd vdd pmos  l = 90n w = 'widthpmos'
mn4 out a pd_n1 gnd nmos  l = 90n w = 3*200n
mn5 pd_n1 b pd_n3 gnd nmos  l = 90n w = 3*200n
mn6 pd_n3 c gnd gnd nmos  l = 90n w = 3*200n
.ENDS nand3


Xdut	low	low	low		outDUT	VDD	GND	nand3
iS	Xdut.out	Xdut.GND	0	exp	(0	'iTotal'	2n	2p	2.1n	1p)

Xinv0	outDut	void	VDD	GND	inverter
Xinv1	outDut	void	VDD	GND	inverter
Xinv2	outDut	void	VDD	GND	inverter
Xinv3	outDut	void	VDD	GND	inverter
.measure	tran	Vpeak	min	v(Xdut.out)	 from = 1.5ns to = 3ns

.model	optmod	opt	itropt = 40
.optimize	opt2	model=optmod	analysisname=tran
.optgoal	opt2	vPeak = 0.0
.paramlimits opt2 'iTotal' minval=20u maxval=2m

.measure tran avgiS			avg i(iS) from = 2ns to = 2.4ns
.measure tran cargaTotal	param = 'avgiS * 0.4n'
.print v(outDUT)


.tran	1p	5ns
.end
