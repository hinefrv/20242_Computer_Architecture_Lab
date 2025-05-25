.data
	A: .word 1, 0, -5, 5, 4, 7, 8, 9, 6
.text
	li s1, 0
	la s2, A
	li s3 ,9
	li s4, 1
	li s5, 0
	li t0, -1
loop:
	# blt s3, s1, endloop # n < i(a)
	# blt s5, zero, endloop # sum < 0 (b)
	beq t0, zero, endloop # A[i] == 0 (c)
	add t1, s1, s1
	add t1, t1, t1
	add t1, t1, s2
	lw t0, 0(t1)
	add s5, s5, t0
	add s1, s1, s4
	j loop
endloop:
