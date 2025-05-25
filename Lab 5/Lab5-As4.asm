.data
string: .space 50
message1: .asciz "Nhap xau: "
message2: .asciz "Do dai xau la: "

.text
main:
get_string:
	la a0, message1 # In "Nhap xau: "
	li a7, 4
	ecall
	la a0, string # Nhap xau mong muon
	li a1, 50
	li a7, 8
	ecall
get_length:
	la a0, string
	li t0, 0
check_char:
	add t1, a0, t0
	lb t2, 0(t1)
	beq t2, zero, end_of_str
	addi t0, t0, 1
	j check_char
end_of_str:
end_of_length:
print_length:
	la a0, message2 # In "Do dai xau la: "
	li a7, 4
	ecall
	addi a0, t0, 0 # In ra do dai cua xau
	li a7, 1
	ecall
	
