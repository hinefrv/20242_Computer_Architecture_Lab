.eqv IN_ADDRESS_HEXA_KEYBOARD       0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD      0xFFFF0014

.text
main:
	li t1, IN_ADDRESS_HEXA_KEYBOARD 
	li t2, OUT_ADDRESS_HEXA_KEYBOARD
polling:
	li t3, 0x01 # row 0
	
scan_rows:
	sb t3, 0(t1) # Ghi dong hien tai vao input
	
	lb a0, 0(t2) # Doc gia tri hien tai vao dia chi input
	beq a0, zero, skip_print # Neu khong co phim nhan, bo qua in
	
	li a7, 34 # in
	ecall
	
	li a0, 100 # sleep
	li a7, 32
	ecall
	
skip_print:
	slli t3, t3, 1 # Dich sang dong tiep theo
	li t4, 0x10
	blt t3, t4, scan_rows # t3 < 0x10, con dong can quet
	
	j polling # quet het 4 dong thi quay lai polling
