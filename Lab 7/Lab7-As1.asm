.text
main:
	li a0, 100
	jal abs
	
	#add a0, s0, zero
	#li a7, 1
	#ecall
	
	li a7, 10
	ecall
end_main:
abs:
	sub s0, zero, a0
	blt a0, zero, done
	add s0, a0, zero
done:
	jr ra
