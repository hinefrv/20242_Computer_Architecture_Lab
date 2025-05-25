.data
A: .word 7, -2, 5, 1, 5, 6, 7, 3, 6, 8, 8, 59, 5 
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
	addi t2, a0, 0 # Sao chep du lieu
	addi t3, a1, 0
outer_loop:
	beq t2, t3, done # Kiem tra dieu kien ket thuc vong lap
	addi t0, t2, 0
	li t6, 0 # Danh dau su thay doi
inner_loop:
	beq t0, t3, end_inner_loop # Kiem tra vong lap trong
	lw t4, 0(t0)
	lw t5, 4(t0)
	ble t4, t5, no_swap # Neu t4 <= t5 khong doi vi tri
	sw t5, 0(t0) # Doi vi tri
	sw t4, 4(t0)
	li t6, 1
no_swap:
	addi t0, t0, 4 # Tro den phan tu ke tiep
	j inner_loop
end_inner_loop:
	beq t6, zero, skip_print # Neu khong co su thay doi nao thi ko in
	la t6, A
	la t1, Aend
	addi t1, t1, -4
print_loop:
	bgt t6, t1, end_print_loop
	lw a0, 0(t6)
	li a7, 1
	ecall
	li a0, 32
	li a7, 11
	ecall
	addi t6, t6, 4
	j print_loop
end_print_loop:
	li a0, 10
	li a7, 11
	ecall
skip_print:
	addi t3, t3, -4 # Lui xuong 1 phan tu
	j outer_loop
done:
	j after_sort