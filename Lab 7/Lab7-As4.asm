.data
message: .asciz "Ket qua tinh giai thua la: "

.text
main:
	jal WARP
print:
	add a1, s0, zero
	li a7, 56
	la a0, message
	ecall
quit:
	li a7, 10
	ecall
end_main:
WARP:
	addi sp, sp, -4
	sw ra, 0(sp)

	li a0, 3
	jal FACT
	
	lw ra, 0(sp)
	addi sp, sp, 4
	jr ra
wrap_end:
FACT:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw a0, 0(sp)
	
	li t0, 2
	bge a0, t0, recursive
	li s0, 1
	j done
recursive:
	addi a0, a0, -1
	jal FACT
	lw s1, 0(sp)
	mul s0, s0, s1
done:
	lw ra, 4(sp)
	lw a0, 0(sp)
	addi sp, sp, 8
	jr ra
fact_end:
