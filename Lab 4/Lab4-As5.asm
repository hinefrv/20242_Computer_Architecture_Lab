.text
	li t1, 7 # So nguyen
	li t2, 16 # Luy thua cua 2
	li t3, 0 # Bien dem
COUNT:
	srli t2, t2, 1 # Dich phai 1 bit (Chia 2)
	beq t2, zero, END # Neu t2 = 0 ket thuc dem
	addi t3, t3, 1 # Tang bien dem
	j COUNT
END:
	addi t5, t1, 0 # Khoi tao tong
LOOP:
	beq t3, zero, ENDLOOP # Neu dem ve 0 thi dung
	slli t5, t5, 1 # Dich trai 1 bit (Nhan 2)
	addi t3, t3, -1 # Giam bien dem
	j LOOP
ENDLOOP:
	
