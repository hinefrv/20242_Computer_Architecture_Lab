.eqv KEY_CODE 0xFFFF0004
.eqv KEY_READY 0xFFFF0000
.eqv DISPLAY_CODE 0xFFFF000C
.eqv DISPLAY_READY 0xFFFF0008

.text
	li a0, KEY_CODE
	li a1, KEY_READY
	li s0, DISPLAY_CODE
	li s1, DISPLAY_READY
	
loop:
WaitForKey:
	lw t1, 0(a1)
	beq t1, zero, WaitForKey
ReadKey:
	lw t0, 0(a0)
WaitForDis:
	lw t2, 0(s1)
	beq t2, zero, WaitForDis
Encrypt:
	addi t0, t0, 1
ShowKey:
	sw t0, 0(s0)
	j loop