.text
start:
	# addi s1, zero, 5
	# addi s1, zero, -5
	addi s1, zero, 2
	addi s2, zero, 3
	add s3, s1, s2
	addi s4, zero, 4 # m
	addi s5, zero, 1 # n
	add s6, s4, s5
	addi t1, zero, 1
	addi t2, zero, 2
	addi t3, zero, 3
	# bge s1, s2, else # i >= j (a)
	# blt s1, s2, else # i < j (b)
	# blt zero, s3, else # i + j > 0 (c)
	bge s6, s3, else # i + j <= m + n (d)
then:
	addi t1, t1, 1
	addi t3, zero, 1
	j endif
else:
	addi t2, t2, -1
	add t3, t3, t3
endif:
