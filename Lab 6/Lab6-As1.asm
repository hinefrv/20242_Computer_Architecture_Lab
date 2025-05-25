.data
A: .word -5, 6, -8, 9, -2, 8
msg: .asciz "Do dai mang con co tong lon nhat: "
msg1: .asciz "Tong lon nhat: "
newline: .asciz "\n"
.text
main:
	la a0, A
	li a1, 6
	j mspfx
continue:
	li a7, 4 # In ra msg
	la a0, msg
	ecall
	li a7, 1 # In ra do dai cua mang con co tong lon nhat (s0)
	addi a0, s0, 0
	ecall
	li a7, 4 # In ra dau xuong dong
	la a0, newline
	ecall
	li a7, 4 # In ra msg1
	la a0, msg1
	ecall
	li a7, 1 # In ra tong lon nhat (s1)
	addi a0, s1, 0
	ecall
exit:
	li a7, 10
	ecall
end_of_main:
mspfx:
	li s0, 0
	li s1, 0x80000000
	li t0, 0
	li t1, 0
loop:
	add t2, t0, t0
	add t2, t2, t2
	add t3, t2, a0
	lw t4, 0(t3)
	add t1, t1, t4
	blt s1, t1, mdfy
	j next
mdfy:
	addi s0, t0, 1
	addi s1, t1, 0
next:
	addi t0, t0 ,1
	blt t0, a1, loop
done:
	j continue
mspfx_end:
