
.include ptm_90nm.l
.param 'supply' = 1.2

vinA 	high	0	PWL(0ns 0		1ns	0			1.001ns	1.2)
r1	high	0 1k

vinB	high1	0	sin (0 1 1G)
r2		high1	0 1k


*fname node1 node2 POLY(N) vname1 [vname2 [vname3]] P0 P1 P2... [Options]
f1	high3 0 poly(2) vinA vinB 0 0 0 0 1
r3	high3	0 1k

.print v(high3)
.tran	1p	5n
.end