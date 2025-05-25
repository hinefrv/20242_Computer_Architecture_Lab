.eqv KEY_CODE 0xFFFF0004
.eqv KEY_READY 0xFFFF0000
.eqv DISPLAY_CODE 0xFFFF000C
.eqv DISPLAY_READY 0xFFFF0008

.data
	exit_str: .ascii "EXIT"
	buffer: .byte 0, 0, 0, 0

.text
	li a0, KEY_CODE
	li a1, KEY_READY
	li s0, DISPLAY_CODE
	li s1, DISPLAY_READY
	la s2, buffer # Dia chi buffer
	li s3, 0 # Bien dem vi tri buffer
	la s4, exit_str # Dia chi chuoi "exit"
	li s5, 4 # Do dai chuoi "exit"

loop:
WaitForKey:
	lw t1, 0(a1)
	beq t1, zero, WaitForKey
ReadKey:
	lw t0, 0(a0)
	
	li t2, 'a' # Kiem tra va xu ly ky tu
	blt t0, t2, CheckUpper # Neu < 'a' kiem tra hoa
	li t2, 'z' 
	bgt t0, t2, Other # Neu > 'z' kiem tra ky tu khac
	
	addi t0, t0, -32 # Neu chu thuong thi viet hoa
	j Char
	
CheckUpper:
	li t2, 'A' # Kiem tra va xu ly ky tu
	blt t0, t2, CheckDigit # Neu < 'A' kiem tra so
	li t2, 'Z'
	bgt t0, t2, Other # Neu > 'Z' kiem tra ky tu khac
	
	addi t0, t0, 32 # Neu chu hoa thi viet thuong
	j Char

CheckDigit:
	li t2, '0'
	blt t0, t2, Other # Neu < '0' kiem tra ky tu khac
	li t2, '9'
	bgt t0, t2, Other # Neu > '9' kiem tra ky tu khac
	j Char

Other:
	li t0, '*' # Thay ky tu khac bang '*'
	
Char:
	bne s3, s5, SkipShift # Meu buffer chua du thi skip shift
	lb t3, 1(s2) # load byte 1 vao byte 0
	sb t3, 0(s2)
	lb t3, 2(s2)
	sb t3, 1(s2)
	lb t3, 3(s2)
	sb t3, 2(s2)
	addi s3, s3, -1 # i -= 1
SkipShift:
	add t3, s2, s3 # Dia chi o trong buffer
	sb t0, 0(t3) # Luu ky tu vao buffer
	addi s3, s3, 1 # i += 1
	blt s3, s5, ExitCheck # Neu buffer chua day thi bo qua
	li s3, 4 
ExitCheck:
	li t3, 0 # j
	blt s3, s5, Display # Neu chua du ky tu thi skip check

ExitLoop:
	bge t3, s5, Exit # Kiem tra du 4 ky tu
	add t4, s2, t3 # Dia chi ky tu trong buffer
	lb t5, 0(t4) # Lay ky tu
	add t6, s4, t3 # Dia chi ky tu "exit"
	lb t6, 0(t6)
	bne t5, t6, Display # Neu khac thi hien thi
	addi t3, t3, 1 # j += 1
	j ExitLoop

Display:
WaitForDis:
	lw t2, 0(s1)
	beq t2, zero, WaitForDis
ShowKey:
	sw t0, 0(s0)
	j loop
Exit:
	li a7, 10
	ecall