
.include ptm_90nm.l
.param 'supply' = 1.2
+	'lambda' = 1.8087
+	'widthPmos' = '200n*lambda'
+	'iTotal' = 6.1193E-4
+	'iHold' = 3.3939E-4
+	'iPrompt' = (iTotal - iHold)
+	 'tF_delay' = 2n

V1		VDD   	0		DC		supply
V2		VDD2  	0		DC		supply

vinA 	high	0	PWL(0ns 0	   	1ns	0	   	1.001ns	supply)
vinB 	low 	0	PWL(0ns supply	1ns	supply	1.001ns	0)

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

Xdut   high	low	low		outDUT	VDD	GND	AOI21
iSp	Xdut.VDD	Xdut.pu_n1	0	exp	(0	'iPrompt'	2n	2p	2.015n	4p)
iSh	Xdut.VDD	Xdut.pu_n1	0	exp	(0	'iHold'	2n	2p	'tF_delay'	4p)
Xinv0	outDut	void	VDD	GND	inverter
Xinv1	outDut	void	VDD	GND	inverter
Xinv2	outDut	void	VDD	GND	inverter
Xinv3	outDut	void	VDD	GND	inverter

.measure tran avgPrompt			avg i(iSp) from = 2ns to = 2.4ns
.measure tran cargaPrompt		param = 'avgPrompt * 0.4n'
.measure tran avgHold			avg i(iSh) from = 2ns to = 2.4ns
.measure tran cargaHold		param = 'avgHold * 0.4n'

.model 		 optmod opt level=1 itropt=40
.optimize 	 opt2 model=optmod analysisname=tran
.optgoal     opt2 cargaHold = 25f
.paramlimits opt2 'tF_delay' minval=2n maxval=3n


.print v(outDUT)
.print i(iSh) i(iSp)

.tran	1p	5ns
.end
