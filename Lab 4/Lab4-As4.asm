.text
	#li s1, 100
	#li s1, 0x7fffffff
	li s1, 0x80000000
	li s2, -1
	li t0, 0 # Danh gia tran so
	add s3, s1, s2
	xor s0, s1, s2 # Kiem tra dau s1 va s2
	blt s0, zero, EXIT # Neu s1 va s2 khac dau, re nhanh EXIT
	xor s0, s1, s3 # Kiem tra dau s3 va s1
	bgt s0, zero, EXIT # Neu dau s3 cung dau s1, re nhanh EXIT
OVERFLOW:
	li t0, 1 # Tran so
EXIT:
