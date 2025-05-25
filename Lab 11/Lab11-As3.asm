.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014

.data
	message: .asciz "Key scan code: "
	
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
	
	xor s0, s0, s0
	
loop:
	addi s0, s0, 1
prn_seq:
	addi a7, zero, 1
	add a0, s0, zero
	ecall
	addi a7, zero, 11
	li a0, '\n'
	ecall
sleep:
	addi a7, zero, 32
	li a0, 300
	ecall
	j loop
end_main:

handler:
	addi sp, sp, -16
	sw a0, 0(sp)
	sw a7, 4(sp)
	sw t1, 8(sp)
	sw t2, 12(sp)
	
prn_msg:
	addi a7, zero, 4
	la a0, message
	ecall
get_key_code:
	li t1, IN_ADDRESS_HEXA_KEYBOARD
	li t2, 0x88
	sb t2, 0(t1)
	li t1, OUT_ADDRESS_HEXA_KEYBOARD
	lb a0, 0(t1)
prn_key_code:
	li a7, 34
	ecall
	li a7, 11
	li a0, '\n'
	ecall

	lw t2, 12(sp)
	lw t1, 8(sp)
	lw a7, 4(sp)
	lw a0, 0(sp)
	addi sp, sp, 16
	
	uret