.data
x: .space 32
y: .asciz "Hello, xau nay co do dai hon 32 ky tu"
newline: .asciz "\n"

.text
strcpy:
	la a0, x
	la a1, y
	add s0, zero, zero
L1:
	add t1, s0, a1
	lb t2, 0(t1)
	add t3, s0, a0
	sb t2, 0(t3)
	beq t2, zero, end_of_strcpy
	addi s0, s0, 1
	j L1
end_of_strcpy:
	la a0, x
	li a7, 4
	ecall
	la a0, newline
	li a7, 4
	ecall
	la a0, y
	li a7, 4
	ecall
