.data
A: .word 5, 6, 9, 2, 3
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
	addi t0, a0, 4 # Sao chep du lieu
outer_loop:
	bgt t0, a1, done  # Xet dieu kien ket thuc vong lap
	lw t2, 0(t0) # key = A[i]
	addi t1, t0, -4 # j = i - 1
inner_loop:
	blt t1, a0, end_inner_loop # Xet dieu kien vong lap
	lw t3, 0(t1) # t3 = A[j]
	ble t3, t2, end_inner_loop # A[j] <= key, ket thuc lap
	sw t3, 4(t1) # A[j + 1] = A[j]
	addi t1, t1, -4 # j = j - 1
	j inner_loop
end_inner_loop:
	sw t2, 4(t1)      # A[j + 1] = key
	la t4, A
	la t5, Aend
	addi t5, t5, -4
print_loop:
	bgt t4, t5, end_print_loop
	lw a0, 0(t4)
	li a7, 1
	ecall
	li a0, 32
	li a7, 11
	ecall
	addi t4, t4, 4
	j print_loop
end_print_loop:
	li a0, 10
	li a7, 11
	ecall
	addi t0, t0, 4 # i = i + 1
	j outer_loop
done:
	j after_sort
