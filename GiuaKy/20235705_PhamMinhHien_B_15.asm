.data
	array: .space 400 # Cho phep nhap 100 so nguyen
	count: .space 400 # Luu so lan xuat hien
	size: .asciz "Nhap kich thuoc mang: "
	number: .asciz "Nhap phan tu thu "
	colon: .asciz ": "
	result: .asciz "Phan tu xuat hien it nhat: "
	fre: .asciz "So lan xuat hien: "
	error_msg: .asciz "Kich thuoc mang phai > 0 hoac < 100"
	newline: .asciz "\n"

	
.text
main:
	la a0, size # Thong bao nhap kich thuoc
	li a7, 4
	ecall
	
	li a7, 5 # Nhap kich thuoc tu ban phim
	ecall
	add t0, a0, zero # Luu kich thuoc vao t0
	
	ble t0, zero, error # Kiem tra kich thuoc neu <= 0 thi bao loi
	li t1, 100
	bgt t0, t1, error # Kich thuoc > 100 thi cung bao loi
	
	la t1, array # Dia chi mang
	li t2, 0 # Bien dem

input:
	beq t2, t0, end_input # Neu nhap du phan tu roi thi bat dau xu ly
	# Nhap phan tu thu i
	la a0, number
	li a7, 4
	ecall
	add a0, zero, t2
	li a7, 1
	ecall
	la a0, colon
	li a7, 4
	ecall
	
	li a7, 5
	ecall
	sw a0, 0(t1)
	addi t1, t1, 4 # Tang dia chi
	addi t2, t2, 1 # i++
	j input
end_input:
	la t1, count # Khoi tao mang dem
	li t2, 0
init:
	# Dam bao khoi tao 100 phan tu
	li s9, 100
	beq t2, s9, count_fre
	sw zero, 0(t1)
	addi t1, t1, 4
	addi t2, t2, 1
	j init
count_fre:
	la t1, array # Dia chi mang
	li t2, 0 # Bien dem
loop:
	beq t2, t0, min # Lap den het kich thuoc mang thi tim min
	lw t3, 0(t1) # t3 = array[i]
	la t4, count
	slli t5, t3, 2 # Tinh dia chi
	add t4, t4, t5 # t4 = &counts[array[i]]
	lw t6, 0(t4) # t6 = counts[array[i]]
	addi t6, t6, 1 # counts[array[i]]++
	sw t6, 0(t4) # Luu gia tri moi vao count[array[i]]
	addi t1, t1, 4
	addi t2, t2, 1
	j loop
min:
	li t2, 101 # t2 = min_freq
	li t3, -1 # t3 = min_value ( phan tu co min_freq)
	la t4, count
	li t5, 0
find:
	beq t5, s9, print
	lw t6, 0(t4)
	beq t6, zero, next # Bo qua neu counts[i] = 0
	bge t6, t2, next # Bo qua neu counts[i] >= min_freq
	add t2, t6, zero
	add t3, t5, zero
next:
	addi t4, t4, 4
	addi t5, t5, 1
	j find
print:
	la a0, result
	li a7, 4
	ecall
	add a0, t3, zero
	li a7, 1
	ecall
	la a0, newline
	li a7, 4
	ecall
	
	la a0, fre
	li a7, 4
	ecall
	add a0, t2, zero
	li a7, 1
	ecall
	j exit

error:
	la a0, error_msg
	li a7, 4
	ecall
	
exit:
	li a7, 10
	ecall