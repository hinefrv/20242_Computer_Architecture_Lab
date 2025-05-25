# Laboratory Exercise 2, Assignment 6 
.data             
	X: .word 5     
	Y: .word -1    
	Z: .word 0     

.text          
	la t5, X       
	la t6, Y       

	lw t1, 0(t5)   # t1 = X 
	lw t2, 0(t6)   # t2 = Y
	add s0, t1, t1 
	add s0, s0, t2 
	# Lưu kết quả từ thanh ghi vào bộ nhớ 
	la t4, Z       
	# Lấy địa chỉ của Z 
	sw s0, 0(t4)   # Lưu giá trị của Z từ thanh ghi vào bộ nhớ 