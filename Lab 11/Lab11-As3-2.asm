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
prn_seg:
	add a0, zero, s0
	li a7, 1
	ecall
	
	li a0, '\n'
	li a7, 11
	ecall
sleep:
	li a0, 300
	li a7, 32
	ecall
	
	j loop
end_main:

handler:
	addi sp, sp, -16
	sw a0, 0(sp)
	sw a7, 4(sp)
	sw t1, 8(sp)
	sw t2, 12(sp)

	li a7, 4
	la a0, message
	ecall

	li t2, 0x80 # Dong dau tien, bit 7 = 1
scan_rows:
	 li t1, IN_ADDRESS_HEXA_KEYBOARD
	sb t2, 0(t1) # Gui dong chon

	li t1, OUT_ADDRESS_HEXA_KEYBOARD
	lb t3, 0(t1) # Doc du lieu tu cot

	beq t3, zero, next_row # Khong co phim thi quet dong khac

	add a0, zero, t3
	li a7, 34
	ecall

	li a7, 11
	li a0, '\n'
	ecall
next_row:
	srli t2, t2, 1 # Sang dong tiep theo
	bnez t2, scan_rows # Neu con dong thi tiep tuc quet

	li t1, IN_ADDRESS_HEXA_KEYBOARD
	li t3, 0x80
	sb t3, 0(t1)

	lw t2, 12(sp)
	lw t1, 8(sp)
	lw a7, 4(sp)
	lw a0, 0(sp)
	addi sp, sp, 16

	uret