.data
	newline: .asciz "\n"
	overflow_msg: .asciz "Overflow error occurred!\n"
	result_msg: .asciz "The result is: "
	num1_msg: .asciz "First number: "
	num2_msg: .asciz "Second number: "

.text
main:
	li sp, 0x7FFFFFF0 # Con tro ngan xep
	la t0, handler
	csrrw zero, utvec, t0
	csrrsi zero, uie, 1 # Kich hoat ngat mem
	csrrsi zero, ustatus, 1 # Kich hoat ngat

	li t0, 0x7fffffff # So nguyen thu 1
	li t1, 1 # So nguyen thu 2
	
	# In so thu nhat
	li a7, 4
	la a0, num1_msg
	ecall
	li a7, 1
	add a0, x0, t0
	ecall
	li a7, 4
	la a0, newline
	ecall
	
	# In so thu hai
	li a7, 4
	la a0, num2_msg
	ecall
	li a7, 1
	add a0, x0, t1
	ecall
	li a7, 4
	la a0, newline
	ecall

	add t2, t0, t1 # t0 + t1

	srli t3, t0, 31 # bit 31 cua t0
	srli t4, t1, 31 # bit 31 cua t1
	srli t5, t2, 31 # bit 31 cua t2
	
	li a7, 1 # In bit 31
	add a0, x0, t3
	ecall
	li a7, 4
	la a0, newline
	ecall
	li a7, 1
	add a0, x0, t4
	ecall
	li a7, 4
	la a0, newline
	ecall
	li a7, 1
	add a0, x0, t5
	ecall
	li a7, 4
	la a0, newline
	ecall
	
	bne t3, t4, no_overflow # Neu bit 31 cua t0 va t1 khac nhau thi khong tran so
	bne t3, t5, overflow # Neu bit 31 cua t0 va t2 khac nhau thi tran so

no_overflow:
	li a7, 4 # In ket qua neu khong tran so
	la a0, result_msg
	ecall
	li a7, 1
	add a0, x0, t2
	ecall
	li a7, 4
	la a0, newline
	ecall
	j exit_program

overflow:
	csrrsi zero, uip, 1 # Kich hoat ngat mem
	j exit_program

handler:
	addi sp, sp, -16 # Luu boi canh
	sw a0, 0(sp)
	sw a7, 4(sp)

	li a7, 4 # In thong bao loi
	la a0, overflow_msg
	ecall
	lw a7, 4(sp) # Khoi phuc va tro ve
	lw a0, 0(sp)
	addi sp, sp, 16
	uret

exit_program:
	li a7, 10
	ecall
