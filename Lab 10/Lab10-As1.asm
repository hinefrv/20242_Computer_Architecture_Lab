.eqv SEVENSEG_LEFT 0xFFFF0011
.eqv SEVENSEG_RIGHT 0xFFFF0010

.text
main:
	# li a0, 0x06
	li a0, 0x3F # Hien thi so 0
	jal SHOW_7SEG_LEFT
	# li a0, 0x3F
	li a0, 0x6D # Hien thi so 5
	jal SHOW_7SEG_RIGHT
exit:
	li a7, 10
	ecall
end_main:
SHOW_7SEG_LEFT:
	li t0, SEVENSEG_LEFT
	sb a0, 0(t0)
	jr ra
SHOW_7SEG_RIGHT:
	li t0, SEVENSEG_RIGHT
	sb a0, 0(t0)
	jr ra
