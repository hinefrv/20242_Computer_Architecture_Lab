.data
message: .asciz "The sum of "
and_msg: .asciz " and "
is_msg: .asciz " is "

.text
	li s0, -10 # Khoi tao s0
	li s1, 20 # Khoi tao s1
	add s2, s0, s1 # Tinh tong s2 = s0 + s1
	la a0, message # In "The sum of "
	li a7, 4
	ecall
	add a0, zero, s0 # In gia tri thu 1
	li a7, 1
	ecall
	la a0, and_msg # In " and "
	li a7, 4
	ecall
	add a0, zero, s1 # In gia tri thu 2
	li a7, 1
	ecall
	la a0, is_msg # In " is "
	li a7, 4
	ecall
	add a0, zero, s2 # In tong
	li a7, 1
	ecall
