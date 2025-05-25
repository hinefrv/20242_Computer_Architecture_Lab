.data
	msg: .asciz "Nhap so nguyen duong N: "
	odd: .asciz "Tong cac chu so la so le: "
	even: .asciz "Tong cac chu so la so chan: "
	newline: .asciz "\n"
	error_msg: .asciz "So phai la nguyen duong !!!"

.text
main:
	la a0, msg # Thong bao nhap so
	li a7, 4
	ecall
	
	li a7, 5 # Nhap so nguyen duong N
	ecall
	add t0, a0, zero # Luu N vao t0
	
	# Kiem tra so nhap vao co nguyen duong hay khong
	beq t0, zero, error
	blt t0, zero, error
	
	li t1, 0 # Khoi tao tong chan
	li t2, 0 # Khoi tao tong le
	
digit:
	beq t0, zero, end # Neu N = 0 thi ket thuc
	li t3, 10
	rem t4, t0, t3 # N % 10 de lay chu so cuoi
	div t0, t0, t3 # N / 10 de bo chu so cuoi
	
	andi t5, t4, 1 # t5 = 1 neu le va = 0 neu chan
	beq t5, zero, even_digit
odd_digit:
	add t1, t1, t4
	j digit
even_digit:
	add t2, t2, t4
	j digit
end:
	# In tong so le
	la a0, odd 
	li a7, 4
	ecall
	add a0, t1, zero
	li a7, 1
	ecall
	la a0, newline
	li a7, 4
	ecall
	
	# In tong chan
	la a0, even
	li a7, 4
	ecall
	add a0, t2, zero
	li a7, 1
	ecall
	la a0, newline
	li a7, 4
	ecall
	
	# Ket thuc
	li a7, 10
	ecall
error:
	la a0, error_msg # Thong bao loi
	li a7, 4
	ecall