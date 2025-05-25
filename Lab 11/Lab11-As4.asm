.eqv IN_ADDRESS_HEXA_KEYBOARD   0xFFFF0012  
.eqv TIMER_NOW                  0xFFFF0018 
.eqv TIMER_CMP                  0xFFFF0020 
.eqv MASK_CAUSE_TIMER           4 
.eqv MASK_CAUSE_KEYPAD          8      
 
.data 
	msg_keypad: .asciz "Someone has pressed a key!\n" 
	msg_timer: .asciz "Time inteval!\n"

.text 
main: 
	la      t0, handler 
	csrrs   zero, utvec, t0 
     
	li      t1, 0x100 
	csrrs   zero, uie, t1
	csrrsi  zero, uie, 0x10
	
	csrrsi  zero, ustatus, 1
	
	li t1, IN_ADDRESS_HEXA_KEYBOARD
	li t2, 0x80
	sb t2, 0(t1)
	
	li t1, TIMER_CMP
	li t2, 1000
	sw t2, 0(t1)
	
loop:
	nop
	nop
	nop
	j loop
end_main:

handler:
	addi sp, sp, -16
	sw a0, 0(sp)
	sw a1, 4(sp)
	sw a2, 8(sp)
	sw a7, 12(sp)
	
	csrr a1, ucause
	li a2, 0x7FFFFFFF
	and a1, a1, a2
	
	li a2, MASK_CAUSE_TIMER
	beq a1, a2, timer_isr
	li a2, MASK_CAUSE_KEYPAD
	beq a1, a2, keypad_isr
	j end_process
	
timer_isr: 
	li a7, 4
	la a0, msg_timer
	ecall
	
	li a0, TIMER_NOW
	lw a1, 0(a0)
	addi a1, a1, 1000
	li a0, TIMER_CMP
	sw a1, 0(a0)
	
	j end_process
keypad_isr: 
	li a7, 4
	la a0, msg_keypad
	ecall
	j end_process

end_process:
	lw a7, 12(sp)
	lw a2, 8(sp)
	lw a1, 4(sp)
	lw a0, 0(sp)
	addi sp, sp, 16
	uret