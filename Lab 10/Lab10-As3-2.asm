.eqv MONITOR_SCREEN 0x10010000
.eqv BLUE 0x000000FF
.eqv WHITE 0x00FFFFFF
.eqv YELLOW 0x00FFFF00
.eqv GREEN 0x0000FF00
.eqv WIDTH 8 # Ban co 8x8

.text
	li a0, MONITOR_SCREEN
	li t1, WIDTH # So hang/cot
	li t2, 0 # i : dem hang
row:
	li t3, 0 # j : dem cot
	andi t4, t2, 1 # Kiem tra chan le, 0 neu chan, 1 neu le
col:
	add t5, t4, t3 # j + i%2
	andi t5, t5, 1 # Kiem tra chan le de chon mau
	
	slli t6, t2, 5 # i * 32 (8 cot 4 byte)
	slli a1, t3, 2 # j * 4
	add a1, a1, t6 # offset
	add a1, a1, a0 # Dia chi o co
	
	beq t5, zero, draw_white
	li a2, YELLOW
	j store_color

draw_white:
	li a2, GREEN

store_color:
	sw a2, 0(a1) # Luu mau vao o
	addi t3, t3, 1 # Tang j
	blt t3, t1, col
	addi t2, t2, 1 # Tang i
	blt t2, t1, row

exit:
	li a7, 10
	ecall