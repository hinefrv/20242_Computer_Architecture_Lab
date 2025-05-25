.text
main:
	li a0, -2
	li a1, 6
	li a2, -9
	jal max
	
	li a7, 1
	add a0, s0, zero
	ecall
	
	li a7, 10
	ecall
end_main:
max:
	add s0, a0, zero
	sub t0, a1, s0
	blt t0, zero, okay
	add s0, a1, zero
okay:
	sub t0, a2, s0
	blt t0, zero, done
	add s0, a2, zero
done:
	jr ra
