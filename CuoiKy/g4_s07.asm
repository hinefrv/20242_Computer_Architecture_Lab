.data
line1:  .asciz "                                            ************* \n" 
line2:  .asciz "**************                             *3333333333333*\n"
line3:  .asciz "*222222222222222*                          *33333******** \n"
line4:  .asciz "*22222******222222*                        *33333*        \n"
line5:  .asciz "*22222*      *22222*                       *33333******** \n"
line6:  .asciz "*22222*        *22222*     *************   *3333333333333*\n"
line7:  .asciz "*22222*        *22222*   **11111*****111*  *33333******** \n"
line8:  .asciz "*22222*        *22222*  **1111**      **   *33333*        \n"
line9:  .asciz "*22222*       *222222*  *1111*             *33333******** \n"
line10: .asciz "*22222*******222222*   *11111*             *3333333333333*\n"
line11: .asciz "*2222222222222222*     *11111*              ************* \n"
line12: .asciz "***************        *11111*                            \n"
line13: .asciz "      ---               *1111**                           \n"
line14: .asciz "    / o o \\              *1111****   *****                \n"
line15: .asciz "    \\   > /               **111111***111*                 \n"
line16: .asciz "     -----                  ***********    dce.hust.edu.vn\n"

menu_message: .asciz "\n\n ----MENU----\n 1. Show picture.\n 2. Show picture with only border.\n 3. Change the order.\n 4. Enter new color number and update.\n 5. Exit.\n Enter your choice: "
error_message: .asciz "Input must be a integer from 1 to 5"

input_d_color: .asciz "Enter color for D (integer from 0-9):"
input_c_color: .asciz "Enter color for C (integer from 0-9):"
input_e_color: .asciz "Enter color for E (integer from 0-9):"

.text 
main_menu:
	# Hiển thị menu
	li a7, 4
	la a0, menu_message
	ecall
	# Nhập lựa chọn từ người dùng
	li a7, 5
	ecall
	add t0, a0, zero # Lưu lựa chọn vào t0

	# Kiểm tra lựa chọn và nhảy đến xử lý tương ứng
	li t1, 1
	beq t0, t1, show_full_picture
	li t1, 2
	beq t0, t1, show_picture_border_only
	li t1, 3
	beq t0, t1, reorder_picture
	li t1, 4
	beq t0, t1, input_and_update_colors
	li t1, 5
	beq t0, t1, program_exit

# Nếu lựa chọn không hợp lệ, in thông báo lỗi và quay lại menu
invalid_choice:
	li a7, 4
	la a0, error_message
	ecall
	j main_menu

# 1. Hiển thị đầy đủ hình ảnh
show_full_picture:
	li t0, 0            # chỉ số dòng hiện tại
	li t1, 16           # tổng số dòng
	la a0, line1        # địa chỉ bắt đầu của dòng đầu tiên
show_full_loop:
	beq t0, t1, main_menu
	li a7, 4
	ecall
	addi a0, a0, 60     # dịch đến dòng tiếp theo
	addi t0, t0, 1
	j show_full_loop

# 2. Hiển thị hình ảnh nhưng bỏ màu (chỉ viền)
show_picture_border_only:
	li t0, 0
	li t1, 16
	li t2, '0'
	li t3, '9'
	li t4, 60
	la a1, line1
border_loop_row:
	beq t0, t1, main_menu
	li t5, 0
border_loop_col:
	beq t5, t4, next_border_row
	lb t6, 0(a1)
	blt t6, t2, print_border_char
	bgt t6, t3, print_border_char
	li t6, ' '
print_border_char:
	li a7, 11
	mv a0, t6
	ecall
	addi t5, t5, 1
	addi a1, a1, 1
	j border_loop_col
next_border_row:
	addi t0, t0, 1
	j border_loop_row

# 3. Đổi thứ tự DCE thành ECD
reorder_picture:
	li t0, 0
	li t1, 16
	la a1, line1
reorder_loop:
	beq t0, t1, main_menu

	sb zero, 22(a1)     # xóa khoảng trắng giữa D và C
	sb zero, 42(a1)     # xóa khoảng trắng giữa C và E
	sb zero, 58(a1)     # xóa ký tự xuống dòng

	# In E
	li a7, 4
	addi a0, a1, 43
	ecall
	# In khoảng trắng
	li a7, 11
	li a0, ' '
	ecall
	# In C
	li a7, 4
	addi a0, a1, 23
	ecall
	# In khoảng trắng
	li a7, 11
	li a0, ' '
	ecall
	# In D
	li a7, 4
	addi a0, a1, 0
	ecall
	# Xuống dòng
	li a7, 11
	li a0, '\n'
	ecall

	# Khôi phục lại ký tự ban đầu
	li t3, ' '
	sb t3, 22(a1)
	sb t3, 42(a1)
	li t3, '\n'
	sb t3, 58(a1)

	addi t0, t0, 1
	addi a1, a1, 60
	j reorder_loop

# 4. Nhập màu mới và cập nhật
input_and_update_colors:
	li a5, 9
# Nhập màu cho D
get_d_color:
	li a7, 4
	la a0, input_d_color
	ecall
	li a7, 5
	ecall
	bltz a0, get_d_color
	bgt a0, a5, get_d_color
	addi t0, a0, '0'
# Nhập màu cho C
get_c_color:
	li a7, 4
	la a0, input_c_color
	ecall
	li a7, 5
	ecall
	bltz a0, get_c_color
	bgt a0, a5, get_c_color
	addi t1, a0, '0'
# Nhập màu cho E
get_e_color:
	li a7, 4
	la a0, input_e_color
	ecall
	li a7, 5
	ecall
	bltz a0, get_e_color
	bgt a0, a5, get_e_color
	addi t2, a0, '0'

# Cập nhật màu trong ảnh
update_color_loop:
	li t3, 0
	li t4, 16
	la a1, line1
	li t6, 60
	li a2, 23     # vị trí bắt đầu của C
	li a3, 43     # vị trí bắt đầu của E
	li a4, '1'
	li a5, '9'
color_row_loop:
	beq t3, t4, show_full_picture
	li t5, 0
color_col_loop:
	beq t5, t6, next_color_row
	blt t5, a2, update_d_color
	blt t5, a3, update_c_color
	j update_e_color
update_d_color:
	lb s1, 0(a1)
	blt s1, a4, skip_update
	bgt s1, a5, skip_update
	sb t0, 0(a1)
	j skip_update
update_c_color:
	lb s1, 0(a1)
	blt s1, a4, skip_update
	bgt s1, a5, skip_update
	sb t1, 0(a1)
	j skip_update
update_e_color:
	lb s1, 0(a1)
	blt s1, a4, skip_update
	bgt s1, a5, skip_update
	sb t2, 0(a1)
skip_update:
	addi t5, t5, 1
	addi a1, a1, 1
	j color_col_loop
next_color_row:
	addi t3, t3, 1
	j color_row_loop

# 5. Thoát chương trình
program_exit:
	li a7, 10
	ecall
