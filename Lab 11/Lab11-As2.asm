.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012
.data
	message: .asciz "Someone's pressed a button.\n"
	
.text
main:
	la t0, handler
	csrrs zero, utvec, t0
	li t1, 0x100
	csrrs zero, uie, t1
	csrrsi zero, ustatus, 1
	
	li t1, IN_ADDRESS_HEXA_KEYBOARD
	li t3, 0x80
	sb t3, 0(t1)
	
loop:
	nop
	nop
	nop
	j loop
end_main:

handler:
	addi sp, sp, -8
	sw a0, 0(sp)
	sw a7, 4(sp)
	
	li a7, 4
	la a0, message
	ecall
	
	lw a7, 4(sp)
	lw a0, 0(sp)
	addi sp, sp, 8
	
	uret