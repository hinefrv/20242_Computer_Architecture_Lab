.text
	li s1, 10
	sub s0, zero, s1 # neg s0, s1
	addi s0, s1, 0 # mv s0, s1
	xori s0, s0, 0xFFFFFFFF # not s0 ( -1 )
	bge s2, s1, EXIT # ble s1, s2, label
START:
	addi s1, s1, 10
EXIT: