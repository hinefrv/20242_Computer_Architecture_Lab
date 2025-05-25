.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv SEVENSEG_LEFT 0xFFFF0011 
.eqv SEVENSEG_RIGHT 0xFFFF0010 
.eqv TIMER_NOW 0xFFFF0018
.eqv TIMER_CMP 0xFFFF0020
.eqv MASK_CAUSE_TIMER 4
.eqv MASK_CAUSE_KEYPAD 8
.eqv SPEED 1000

.data
	LED: .word 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71
	Mode: .byte 0x11, 0x21, 0x41, 0x81

.text
main:
	la t0, handler
	csrrs zero, utvec, t0
   
	li t1, 0x100
	csrrs zero, uie, t1 # uie - ueie bit (bit ? - external interrupt
	csrrsi zero, uie, 0x10 # uie - utie bit (bit 4) - timer interrupt
	csrrsi zero, ustatus, 1 # ustatus - enable uie - global interrupt
 
	li s11, 100 # Gioi han tren bo dem
	li s10, 10 # Hang so
	li s9, 4 # 4 bytes
	la s8, LED
	li s3, 2 # He so tang giam SPEED
	li s2, 9000 # Gioi han SPEED
 
	# Enable the interrupt of keypad of Digital Lab Sim
	li t1, IN_ADDRESS_HEXA_KEYBOARD
	li t2, 0x81 # bit 7 of = 1 to enable interrupt
	sb t2, 0(t1)
	# Enable the timer interrupt
	li t6, SPEED
	li t1, TIMER_CMP
	li t2, SPEED
	sw t2, 0(t1)
loop:
	nop
	nop
	nop
	j loop
end_main:
handler:
	# Saves the context
	addi sp, sp, -16
	sw a0, 0(sp)
	sw a1, 4(sp)
	sw a2, 8(sp)
	sw a7, 12(sp)

	# Handles the interrupt
	csrr a1, ucause
	li a2, 0x7FFFFFFF
	and a1, a1, a2 # Clear interrupt bit to get the value
	li a2, MASK_CAUSE_TIMER
	beq a1, a2, timer_isr
	li a2, MASK_CAUSE_KEYPAD
	beq a1, a2, keypad_isr
	j end_process

timer_isr:
	j count
timer_update:
	# Set cmp to time + 1000
	li a0, TIMER_NOW
	lw a1, 0(a0)
	add a1, a1, t6 # Them SPEED de tinh thoi gisn ngat ke tiep
	li a0, TIMER_CMP
	sw a1, 0(a0) # Ghi thoi gian moi de dinh thoi ngat ke tiep

	j end_process
keypad_isr:
	li a4, IN_ADDRESS_HEXA_KEYBOARD
	li a3, 0x81 # bit 7 of = 1 to enable interrupt
	sb a3, 0(a4)
	li a5, OUT_ADDRESS_HEXA_KEYBOARD
	lb s6, 0(a5) # Doc phim nhan
	la a4, Mode
	lb s5, 0(a4) # So sanh voi mode[0] (0x11)
	bne s6, s5, check # Neu khong phai 0x11
	addi s4, zero, 0 # Dem tang
	j end_process
 
check:
	lb s5, 1(a4) # mode[1] = 0x21
	bne s6, s5, second_check # Phim khac 1 thi kiem tra second_check
	addi s4, zero, 1 # Dem giam
	j end_process
 
second_check:
	lb s5, 2(a4) # mode[2] = 0x41
	bne s6, s5, down_speed # Neu la 0x41 thi giam toc do
	j up_speed # Neu la 0x81 thi tang toc do


end_process:
	# Restores the context
	lw a7, 12(sp)
	lw a2, 8(sp)
	lw a1, 4(sp)
	lw a0, 0(sp)
	addi sp, sp, 16
	uret 

count:
	beq s4, zero, up
down:
	addi t5, t5, -1
	bne t5, zero, show
	addi t5, zero, 100
	j show
up:
	addi t5, t5, 1
	bne t5, s11, show
	addi t5, zero, -1
show:
	rem t4, t5, s10 # Hang don vi
	mul t4, t4, s9
	add t3, s8, t4 
	lw t4, 0(t3)
	jal SHOW_7SEG_RIGHT
	div t4, t5, s10 # Hang chuc
	rem t4, t4, s10
	mul t4, t4, s9
	add t3, s8, t4 
	lw t4, 0(t3)
	jal SHOW_7SEG_LEFT
	j timer_update

SHOW_7SEG_LEFT:
	li s7, SEVENSEG_LEFT # assign port's address
	sb t4, 0(s7) # assign new value
	jr ra

SHOW_7SEG_RIGHT:
	li s7, SEVENSEG_RIGHT # assign port's address
	sb t4, 0(s7) # assign new value
	jr ra  
 
up_speed:
	bgt t6, s2, end_process
	mul t6, t6, s3
	j end_process 
down_speed:
	blt t6, s11, end_process
	div t6, t6, s3
	j end_process
