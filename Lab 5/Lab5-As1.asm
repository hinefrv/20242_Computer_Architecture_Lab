.data
# test: .asciz "Hello World"
test: .asciz "Huster"
.text
	li a7, 4
	la a0, test
	ecall
