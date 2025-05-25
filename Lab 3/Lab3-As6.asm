.data
	A: .word 1, 7, 2, -5, 4, -15
.text
	li s1, 0 # i
	la s2, A # A address
	li s3 ,6 # n
	li s4, 1 # step
	li s5, 0 # max
loop:
	bge s1, s3, endloop # i >= n, endloop
	add t1, s1, s1    
	add t1, t1, t1    
	add t1, t1, s2    
	lw  t0, 0(t1)
	blt t0, zero, absolute # neu A[i] < 0, lay tri tuyet doi
	blt s5, t0, findmax # neu A[i] > max, max = A[i]
	add s1, s1, s4 # step + 1
	j loop
absolute:
	sub t0, zero, t0 # t0 = 0 - t0
	blt s5, t0, findmax
	add s1, s1, s4
	j loop
findmax:
	add s5, zero, t0
	add s1, s1, s4
	j loop
endloop:
