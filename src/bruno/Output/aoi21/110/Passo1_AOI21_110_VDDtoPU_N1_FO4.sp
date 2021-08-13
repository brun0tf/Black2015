
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

.subckt AOI21 inA	inB	inC	out	VDD	GND
MP1	out	inB	pu_n1	VDD	pmos	L = 90n  W = 'widthPmos*2'
MP2	pu_n1	inC	out	VDD	pmos	L = 90n  W = 'widthPmos*2'
MP3	pu_n1	inA	VDD	VDD	pmos	L = 90n  W = 'widthPmos*2'
MN4	GND	inA	out	GND	nmos	L = 90n  W = 200n
MN5	GND	inC	pd_n1	GND	nmos	L = 90n  W = 2*200n
MN6	pd_n1	inB	out	GND	nmos	L = 90n  W = 2*200n
.ends AOI21


Xdut	high	high	low		outDUT	VDD	GND	AOI21
iS	Xdut.VDD	Xdut.pu_n1	0	exp	(0	'iTotal'	2n	2p	2.015n	4p)

Xinv0	outDut	void	VDD	GND	inverter
Xinv1	outDut	void	VDD	GND	inverter
Xinv2	outDut	void	VDD	GND	inverter
Xinv3	outDut	void	VDD	GND	inverter

.measure	tran	Vpeak	max	v(Xdut.pu_n1)	 from = 1.5ns to = 3ns

.model	optmod	opt	itropt = 40
.optimize	opt2	model=optmod	analysisname=tran
.optgoal	opt2	vPeak = 1.2
.paramlimits opt2 'iTotal' minval=20u maxval=2m

.measure tran avgiS			avg i(iS) from = 2ns to = 2.4ns
.measure tran cargaTotal	param = 'avgiS * 0.4n'
.print v(outDUT)

.tran	1p	5ns
.end
