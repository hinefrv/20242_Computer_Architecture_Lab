.eqv SEVENSEG_LEFT 0xFFFF0011
.eqv SEVENSEG_RIGHT 0xFFFF0010

.data
	SEG7_TABLE: .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
.text
	li a7, 12 # Nhap ky tu
	ecall
	add t1, zero, a0 # Sao chep ma ASCII vao t1
	
	addi t2, zero, 100 # Lay 2 chu so cuoi
	rem t1, t1, t2 # t1 = ASCII % 100
	
	addi t2, zero, 10 # Tach chu so hang chuc va don vi
	div t3, t1, t2 # s2 = s1 / 10
	rem t4, t1, t2 # s3 = s1 % 10
	
	la t5, SEG7_TABLE
	lb a0, 0(t5)
	
	slli t3, t3, 0 # Hien thi LED trai (hang chuc)
	add t6, t5, t3
	lb a0, 0(t6)
	jal SHOW_7SEG_LEFT
	
	slli t4, t4, 0 # Hien thi LED phai (hang don vi)
	add t6, t5, t4
	lb a0, 0(t6)
	jal SHOW_7SEG_RIGHT
			
exit:
	li a7, 10
	ecall
	
SHOW_7SEG_LEFT:
	li t0, SEVENSEG_LEFT
	sb a0, 0(t0)
	jr ra
	
SHOW_7SEG_RIGHT:
	li t0, SEVENSEG_RIGHT
	sb a0, 0(t0)
	jr ra
