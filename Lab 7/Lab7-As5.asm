.data
largest: .asciz "Largest: "
smallest: .asciz "Smallest: "
space: .asciz ", "
newline: .asciz "\n"

.text
main:
	addi sp, sp, -32 # Cap phat 32 bytes cho 8 so
	li a0, -99
	sw a0, 0(sp)
	li a1, 18
	sw a1, 4(sp)
	li a2, -5
	sw a2, 8(sp)
	li a3, 0
	sw a3, 12(sp)
	li a4, 3
	sw a4, 16(sp)
	li a5, 2
	sw a5, 20(sp)
	li a6, -7
	sw a6, 24(sp)
	li a7, 8
	sw a7, 28(sp)
	
	lw t0, 0(sp) # temp_max
	lw t1, 0(sp) # temp_min
	li t2, 0 # Vi tri max
	li t3, 0 # Vi tri min
	li t5, 1 # Bo dem
	addi t4, sp ,4 # Tro den vi tri ke tiep
	li s8, 8
	
	jal loop
	
	jal print
	
	li a7, 10
	ecall
	
loop:
	bge t5, s8, end_loop # Neu da duyet het 8 so thi out
	lw t6, 0(t4) # Load gia tri tu stack
	bgt t6, t0, max
min_check:
	blt t6, t1, min
update_vitri:
	addi t4, t4, 4 # Tang con tro
	addi t5, t5, 1 # Tang bo dem
	j loop
max:
	addi t0, t6, 0 # Cap nhat max
	addi t2, t5, 0 # Cap nhat vi tri max
	j min_check
min:
	addi t1, t6, 0 # Cap nhat min
	addi t3, t5, 0 # Cap nhat vi tri min
	j update_vitri
end_loop:
	jr ra
print:
	la a0, largest
	li a7, 4
	ecall
	
	addi a0, t0, 0
	li a7, 1
	ecall
	
	la a0, space
	li a7, 4
	ecall
	
	addi a0, t2, 0
	li a7, 1
	ecall
	
	la a0, newline
	li a7, 4
	ecall
	
	la a0, smallest
	li a7, 4
	ecall
	
	addi a0, t1, 0
	li a7, 1
	ecall
	
	la a0, space
	li a7, 4
	ecall
	
	addi a0, t3, 0
	li a7, 1
	ecall
	

	
	jr ra
