# Laboratory Exercise 3, Assignment 1
.text
start:
	addi s1, zero, 2
	# addi s1, zero, 5
	addi s2, zero, 3
	addi t1, zero, 1
	addi t2, zero, 2
	addi t3, zero, 3
	blt s2, s1, else
then:
	addi t1, t1, 1
	addi t3, zero, 1
	j endif
else:
	addi t2, t2, -1
	add t3, t3, t3
endif:
