.text
	li s0, 0x12345678
	# Trich xuat MSB
	srli t0, s0, 24
	andi t1, t0,  0xff
	# Xoa LSB
	andi s0, s0, 0xffffff00
	# Thiet lap LSb
	ori s0, s0, 0xff
	# Xoa s0
	xor s0, s0, s0
	