.data
A: .word -7, -2, 5, 1, 58, 64, 17, 3, 6, 9, 8, 59, 55
Aend: .word

.text
main:
	la a0, A
	la a1, Aend
	addi a1, a1, -4
	j sort
after_sort:
	li a7, 10
	ecall
end_main:
sort:
	beq a0, a1, done
	j max
after_max:
	lw t0, 0(a1)
	sw t0, 0(s0)
	sw s1, 0(a1)
	addi a1, a1, -4
	j print # In mang
	j sort
done:
	j after_sort
max:
	addi s0, a0, 0
	lw s1, 0(s0)
	addi t0, a0, 0
loop:
	beq t0, a1, ret
	addi t0, t0, 4
	lw t1, 0(t0)
	blt t1, s1, loop
	addi s0, t0, 0
	addi s1, t1, 0
	j loop
ret:
	j after_max
print:
	addi t2, a0, 0 # Sao chep du lieu thanh ghi a0
	addi t3, a1, 0 # Sao chep du lieu thanh ghi a1
	la t0, A
	la t1, Aend # Lay vi tri cuoi cua mang
	addi t1, t1, -4
print_loop:
	bgt t0, t1, endloop
	lw a0, 0(t0) # In tung phan tu
	li a7, 1
	ecall
	li a0, 32 # In dau cach
	li a7, 11
	ecall
	addi t0, t0, 4 # Chuyen sang phan tu tiep theo
	j print_loop
endloop:
	li a0, 10 # In newline
	li a7, 11
	ecall
	addi a0, t2, 0 # Khoi phuc du lieu
	addi a1, t3, 0 # Khoi phuc du lieu
	j sort
