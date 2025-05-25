.data
	A: .word 1, 3, 2, 5
	# A: .word 1, 3, 2, 5, 4, 7, 8, 9, 6
.text
	li s1, 0
	la s2, A
	li s3 ,4
	# li s3, 9
	li s4, 2
	li s5, 0
loop:
	bge s1, s3, endloop
	add t1, s1, s1
	add t1, t1, t1
	add t1, t1, s2
	lw t0, 0(t1)
	add s5, s5, t0
	add s1, s1, s4
	j loop
endloop:
	
	
