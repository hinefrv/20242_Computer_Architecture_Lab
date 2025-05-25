.eqv MONITOR_SCREEN 0x10010000
.eqv RED 0x00FF0000
.eqv BLACK 0xFF000000
.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014


.text
main:
	addi sp, sp, -16
	addi t0, x0, 1
	addi t1, x0, 2
	addi t2, x0, 4
	addi t3, x0, 8
	sw t0, 0(sp)
	sw t1, 4(sp)
	sw t2, 8(sp)
	sw t3, 12(sp)
	
	li s10, MONITOR_SCREEN # Luu dia chi pixel dc to
	la t0, handler # Lay dia chi ham handler
	csrrs zero, utvec, t0
	li t1, 0x100 # Bit 8 = 1 (0x100)
	csrrs zero, uie, t1 # Thiet lap bit UEIE trong thanh ghi uie
	csrrsi zero, ustatus, 1 # Bit 0 trong ustatus
	
	li t1, IN_ADDRESS_HEXA_KEYBOARD
	li t3, 0x80 # Bit 7 = 1
	sb t3, 0(t1) # Kich hoat ngat
loop:
	j loop
end_main:
handler:
	li s9, BLACK
	sw s9, 0(s10) # To den o cu
get_key_code:
	li t1, IN_ADDRESS_HEXA_KEYBOARD
	li t2, 0x80 # Bat lai bit 7 de doc hang
	li t3, 0
	li t4, 0x01 # Hang dau tien (bit 0)
	li t5, 2
read:
	add t6, t2, t4 # Ket hop dong can doc voi bat ngat
	sb t6, 0(t1) # Doc hang moi
	mul t4, t4, t5 # Hang tiep theo
	li s0, OUT_ADDRESS_HEXA_KEYBOARD
	lbu a0, 0(s0) # Doc byte 8 bit
	addi s9, a0, 0 # Luu ma
	
	beq a0, zero, read # Neu chua bam phim nao, doc lai
	li t6, MONITOR_SCREEN
	li t5, 4 # 4 o moi hang
	addi a2, sp, 0 # Tro den gia tri hang
	jal row_col # Tim chi so hang
	mul t1, t1, t5 # row * 4
	add t6, t6, t1 # + dia chi man hinh
	srli a0, a0, 4 # Gia tri cot
	jal row_col
	add t6, t6, t1 # Hang + Cot
	li s2, RED 
	sw s2, 0(t6) # To do
	addi s10, t6, 0 # Cap nhat vi tri o mau hien tai
	uret # Tra quyen dieu khien
row_col:
	andi t0, a0, 0xf # Giu lai 4 bit cuoi
	addi t1, x0, 0 # i = 0
for:
	add a3, a2, t1 # Tro toi phan tu mang i
	lw t3, 0(a3) # Gia tri tai i
	beq t3, t0, end_rc # Neu ma phim dang xu ly thi dung
	addi t1, t1, 4 # Tang i
	j for
end_rc: 
	jr ra