.text
	#li s1, -10
	#li s1, 0x7FFFFFFF
	li s1, 0x80000000
	li s2, -1
	li t0, 0
	add s3, s1, s2
	xor t1, s1, s2
	blt t1, zero, EXIT
	blt s1, zero, NEGATIVE
	bge s3, s1, EXIT
	j OVERFLOW
NEGATIVE:
	bge s1, s3, EXIT
OVERFLOW:
 	li t0, 1
EXIT:
