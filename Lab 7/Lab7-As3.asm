.text
main:
	li s0, 1
	li s1, 2
push:
	addi sp, sp, -8
	sw s0, 4(sp)
	sw s1, 0(sp)
work:
	add a0, s0, zero
	li a7, 1
	ecall
	add a0, s1, zero
	li a7, 1
	ecall
pop:
	lw s0, 0(sp)
	lw s1, 4(sp)
	addi sp, sp, 8
	add a0, s0, zero
	li a7, 1
	ecall
	add a0, s1, zero
	li a7, 1
	ecall
