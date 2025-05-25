.data
	strA: .space 100 # Chuoi A toi da 100 ky tu
	strB: .space 100 # Chuoi B toi da 100 ky tu
	freA: .space 128 # Bang dem tan suat ky tu
	freB: .space 128
	inputA: .asciz "Nhap chuoi A: "
	inputB: .asciz "Nhap chuoi B: "
	newline: .asciz "\n"
	yes: .asciz "A va B la anagram."
	no: .asciz "A va B khong la anagram."
	
.text
main:
	la a0, inputA # Nhap chuoi A
	li a7, 4
	ecall
	la a0, strA
	li a1, 100
	li a7, 8
	ecall
	
	la a0, inputB # Nhap chuoi B
	li a7, 4
	ecall
	la a0, strB
	li a1, 100
	li a7, 8
	ecall
	
	
	
	# Tinh freA
	la a0, strA
	la a1, freA
	jal count
	
	# Tinh freB
	la a0, strB
	la a1, freB
	jal count
	
	# So sanh tan suat
	la a0, freA
	la a1, freB
	jal compare
	
	li a0, 1
	beq a0, a2, print_yes
	
print_no:
	la a0, no
	li a7, 4
	ecall
	j exit
print_yes:
	la a0, yes
	li a7, 4
	ecall
exit:
	li a7, 10
	ecall
count:
	lb t0, 0(a0) # Lay tung ky tu trong chuoi
	beq t0, zero, end 
	add t3, a1, t0 # Tinh dia chi cua fre[t0]
	lb t2, 0(t3) # Lay gia tri hien tai trong fre[t0]
	addi t2, t2, 1 # Tang gia tri them 1
	sb t2, 0(t3) # Cap nhat gia tri t3
	addi a0, a0, 1 # Ky tu tiep theo
	j count
end:
	jr ra
compare:
	li t0, 0 # i
loop:
	li s9, 128 # 128 ki tu
	bge t0, s9, fre_equal
	add t3, a0, t0 # Dia chi freA[t0]
	add t4, a1, t0 # Dia chi freB[t0]
	lb t1, 0(t3) # Lay gia tri
	lb t2, 0(t4)
	bne t1, t2, fre_not_equal
	addi t0, t0, 1
	j loop
fre_equal:
	li a2, 1
	jr ra
fre_not_equal:
	li a2, 0
	jr ra