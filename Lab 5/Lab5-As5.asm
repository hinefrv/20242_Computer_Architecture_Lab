.data
message: .asciz "Nhap xau: "
message1: .asciz "Chuoi dao nguoc: "
counter: .space 21

.text
main:
	la a0, message # Hien thi thong bao nhap
	li a7, 4 
	ecall
	la t0, counter # Khoi tao bo dem
	li t1, 0
loop:
	li a7, 12 # Doc 1 ky tu
	ecall
	li t2, 10 # Kiem tra neu la 10 ('\n') thi ket thuc
	beq a0, t2, end_loop
	sb a0, 0(t0) # Luu ky tu
	addi t0, t0, 1 # Tang dia chi luu
	addi t1, t1, 1 # Tang bo dem
	li t3, 20 # Kiem tra 20 ky tu
	bge t1, t3, end_loop
	j loop
end_loop:
	sb zero, 0(t0) # Them ky tu '\n'
	li a7, 4 # Hien thi thong bao xuat
	la a0, message1
	ecall
	la t0, counter # In nguoc chuoi
	add t0 ,t0 ,t1 # Tro den ky tu cuoi cung
reverse:
	addi t0, t0, -1 # Lui ve ky tu truoc
	lb a0, 0(t0) # Lay ky tu
	li a7, 11 # In ky tu
	ecall
	addi t1, t1, -1 # Giam bo dem
	bgt t1, zero, reverse
end:
	
