.eqv MONITOR_SCREEN  0x10010000          # Địa chỉ bắt đầu của màn hình bitmap
.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012 # Địa chỉ để gửi mã quét bàn phím HEX
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014 # Địa chỉ để đọc mã phím từ bàn phím HEX
.eqv MAX_ROW_SCAN_VAL 0x08               # Giá trị tối đa cho quét hàng (2^3 = 8)
.eqv ORANGE        0x00FFA500            # Mã màu cam (cho ký hiệu X)
.eqv BLUE          0x000000FF            # Mã màu xanh dương (cho ký hiệu O)
.eqv WHITE         0x00FFFFFF            # Mã màu trắng (cho lưới)
#.eqv BACKGROUND    0x00eeeeee            # Mã màu giống giao diện của Bitmap (cho lưới)
.eqv BLACK         0x00000000            # Mã màu đen (cho vùng trống)

.data 0x10010400
board_state:    .space 64       # Mảng 16 ô (4x4), mỗi ô 4 byte, lưu trạng thái bàn cờ
                                # 0: ô trống, 1: X, 2: O
current_player: .word 1         # Người chơi hiện tại (1 = X, 2 = O)
score_X:        .word 0         # Điểm số của người chơi X
score_O:        .word 0         # Điểm số của người chơi O
draw_count:     .word 0         # Số lần hòa
moves_made:     .word 0         # Số nước đi đã thực hiện trong ván hiện tại
last_winner:    .word 0         # Lưu người đi đầu ván trước (0: ván đầu, 1: X, 2: O)
msg_X_wins:     .asciz "Player X WINS!\n" # Thông báo khi X thắng
msg_O_wins:     .asciz "Player O WINS!\n" # Thông báo khi O thắng
msg_draw:       .asciz "It's a DRAW!\n"   # Thông báo khi hòa
msg_score_is:   .asciz "Score: Player X - "      # Chuỗi hiển thị điểm số X
msg_draw_sep:   .asciz " | Draw - "       # Chuỗi phân cách điểm hòa
msg_O_score_sep:.asciz " | Player O - "          # Chuỗi phân cách điểm O
space_char:     .asciz " "                # Ký tự khoảng trắng
newline:        .asciz "\n"               # Ký tự xuống dòng
game_over_flag: .word 0                   # Cờ báo hiệu trò chơi kết thúc (0: đang chơi, 1: kết thúc)

.text

#-------------------------------------------------------------------------------
# main: Điểm bắt đầu của chương trình
#-------------------------------------------------------------------------------
main:
    # Thiết lập xử lý ngắt (interrupt) cho bàn phím HEX
    la t0, handler              # Tải địa chỉ hàm xử lý ngắt (handler)
    csrrw zero, utvec, t0       # Ghi địa chỉ handler vào thanh ghi utvec
    li t1, 0x100                # Bit mask để kích hoạt ngắt bàn phím
    csrrs zero, uie, t1         # Kích hoạt ngắt bàn phím trong uie
    csrrsi zero, ustatus, 1     # Kích hoạt chế độ ngắt người dùng (ustatus)
    li t1, IN_ADDRESS_HEXA_KEYBOARD # Tải địa chỉ gửi mã quét bàn phím
    li t3, 0x80                 # Mã kích hoạt bàn phím
    sb t3, 0(t1)                # Gửi mã kích hoạt đến bàn phím
    jal init_game_state         # Gọi hàm khởi tạo trạng thái trò chơi
loop:
    nop                         # Vòng lặp vô hạn chờ ngắt từ bàn phím
    j loop
end_main:

#-------------------------------------------------------------------------------
# handler: Hàm xử lý ngắt bàn phím
# Mô tả: Xử lý khi người chơi nhấn phím HEX, ánh xạ phím thành tọa độ ô,
# cập nhật bàn cờ, vẽ X/O, kiểm tra thắng/thua/hòa, và chuyển lượt.
# Thanh ghi sử dụng:
# t0, t1, t2, t3, t5, a0, s2, s3
#-------------------------------------------------------------------------------
handler:
    lw t0, game_over_flag       # Đọc cờ kết thúc trò chơi
    bne t0, zero, restore_context_no_action # Nếu trò chơi đã kết thúc, không xử lý
    addi sp, sp, -32            # Cấp phát 32 byte trên stack để lưu thanh ghi
    sw ra, 28(sp)               # Lưu địa chỉ trở về
    sw a0, 24(sp)               # Lưu a0
    sw t1, 20(sp)               # Lưu t1
    sw t2, 16(sp)               # Lưu t2
    sw t3, 12(sp)               # Lưu t3
    sw t5, 8(sp)                # Lưu t5
    sw s2, 4(sp)                # Lưu s2
    sw s3, 0(sp)                # Lưu s3
    li t3, 0x01                 # Khởi tạo mã quét hàng (bắt đầu từ hàng 0)
key_scan_loop_handler:
    li t1, IN_ADDRESS_HEXA_KEYBOARD # Tải địa chỉ gửi mã quét
    ori t2, t3, 0x80            # Thêm bit kích hoạt (0x80) vào mã quét
    sb t2, 0(t1)                # Gửi mã quét đến bàn phím
    nop                         # Đợi một chu kỳ
    li t1, OUT_ADDRESS_HEXA_KEYBOARD # Tải địa chỉ đọc mã phím
    lbu a0, 0(t1)               # Đọc mã phím (unsigned byte)
    beq a0, zero, next_row_handler # Nếu không có phím được nhấn, quét hàng tiếp theo
    li t2, -1                   # Khởi tạo t2 = -1 (chỉ số ô không hợp lệ)
    li t5, 0                    # Khởi tạo t5 = 0 (offset trên màn hình bitmap)
    # Ánh xạ mã phím HEX thành chỉ số ô (0-15) và offset trên màn hình
    li s3, 0x11
    beq a0, s3, map_key_0_0     # Phím (0,0) -> ô 0
    li s3, 0x21
    beq a0, s3, map_key_0_1     # Phím (0,1) -> ô 1
    li s3, 0x41
    beq a0, s3, map_key_0_2     # Phím (0,2) -> ô 2
    li s3, 0x81
    beq a0, s3, map_key_0_3     # Phím (0,3) -> ô 3
    li s3, 0x12
    beq a0, s3, map_key_1_0     # Phím (1,0) -> ô 4
    li s3, 0x22
    beq a0, s3, map_key_1_1     # Phím (1,1) -> ô 5
    li s3, 0x42
    beq a0, s3, map_key_1_2     # Phím (1,2) -> ô 6
    li s3, 0x82
    beq a0, s3, map_key_1_3     # Phím (1,3) -> ô 7
    li s3, 0x14
    beq a0, s3, map_key_2_0     # Phím (2,0) -> ô 8
    li s3, 0x24
    beq a0, s3, map_key_2_1     # Phím (2,1) -> ô 9
    li s3, 0x44
    beq a0, s3, map_key_2_2     # Phím (2,2) -> ô 10
    li s3, 0x84
    beq a0, s3, map_key_2_3     # Phím (2,3) -> ô 11
    li s3, 0x18
    beq a0, s3, map_key_3_0     # Phím (3,0) -> ô 12
    li s3, 0x28
    beq a0, s3, map_key_3_1     # Phím (3,1) -> ô 13
    li s3, 0x48
    beq a0, s3, map_key_3_2     # Phím (3,2) -> ô 14
    li s3, 0x88
    beq a0, s3, map_key_3_3     # Phím (3,3) -> ô 15
    j process_move_logic         # Nếu mã phím không khớp, xử lý nước đi
map_key_0_0:
    li t2, 0                    # Ô 0
    li t5, 0                   # Offset trên màn hình cho ô (0,0)
    j process_move_logic
map_key_0_1:
    li t2, 1                    # Ô 1
    li t5, 16                   # Offset cho ô (0,1)
    j process_move_logic
map_key_0_2:
    li t2, 2                    # Ô 2
    li t5, 32                  # Offset cho ô (0,2)
    j process_move_logic
map_key_0_3:
    li t2, 3                    # Ô 3
    li t5, 48                  # Offset cho ô (0,3)
    j process_move_logic
map_key_1_0:
    li t2, 4                    # Ô 4
    li t5, 256                  # Offset cho ô (1,0)
    j process_move_logic
map_key_1_1:
    li t2, 5                    # Ô 5
    li t5, 272                  # Offset cho ô (1,1)
    j process_move_logic
map_key_1_2:
    li t2, 6                    # Ô 6
    li t5, 288                  # Offset cho ô (1,2)
    j process_move_logic
map_key_1_3:
    li t2, 7                    # Ô 7
    li t5, 304                  # Offset cho ô (1,3)
    j process_move_logic
map_key_2_0:
    li t2, 8                    # Ô 8
    li t5, 512                  # Offset cho ô (2,0)
    j process_move_logic
map_key_2_1:
    li t2, 9                    # Ô 9
    li t5, 528                  # Offset cho ô (2,1)
    j process_move_logic
map_key_2_2:
    li t2, 10                   # Ô 10
    li t5, 544                  # Offset cho ô (2,2)
    j process_move_logic
map_key_2_3:
    li t2, 11                   # Ô 11
    li t5, 560                  # Offset cho ô (2,3)
    j process_move_logic
map_key_3_0:
    li t2, 12                   # Ô 12
    li t5, 768                  # Offset cho ô (3,0)
    j process_move_logic
map_key_3_1:
    li t2, 13                   # Ô 13
    li t5, 784                  # Offset cho ô (3,1)
    j process_move_logic
map_key_3_2:
    li t2, 14                   # Ô 14
    li t5, 800                  # Offset cho ô (3,2)
    j process_move_logic
map_key_3_3:
    li t2, 15                   # Ô 15
    li t5, 816                  # Offset cho ô (3,3)
    j process_move_logic
process_move_logic:
    li s3, -1                   # Kiểm tra nếu chỉ số ô không hợp lệ
    beq t2, s3, restore_context_handler # Nếu t2 = -1, khôi phục ngữ cảnh
    la s2, board_state          # Tải địa chỉ mảng trạng thái bàn cờ
    slli t1, t2, 2              # Tính offset ô (ô * 4 byte)
    add s3, s2, t1              # s3 = địa chỉ ô trong board_state
    lw t0, 0(s3)                # Đọc trạng thái ô
    bne t0, zero, restore_context_handler # Nếu ô đã được đánh, bỏ qua
    la s2, current_player       # Tải địa chỉ người chơi hiện tại
    lw s3, 0(s2)                # Đọc người chơi hiện tại (1 = X, 2 = O)
    la t0, board_state          # Tải địa chỉ mảng trạng thái bàn cờ
    slli t1, t2, 2              # Tính offset ô
    add t0, t0, t1              # t0 = địa chỉ ô cần cập nhật
    sw s3, 0(t0)                # Lưu người chơi (X hoặc O) vào ô
    la t0, moves_made           # Tải địa chỉ biến số nước đi
    lw t1, 0(t0)                # Đọc số nước đi
    addi t1, t1, 1              # Tăng số nước đi
    sw t1, 0(t0)                # Lưu số nước đi mới
    li s0, MONITOR_SCREEN        # Tải địa chỉ màn hình bitmap
    add s0, s0, t5              # Thêm offset để vẽ tại ô tương ứng
    li t0, 1                    # Kiểm tra người chơi
    beq s3, t0, draw_player_X_handler # Nếu người chơi là X, vẽ X
    li s1, BLUE                # Màu xanh dương cho O
    jal draw_O                  # Gọi hàm vẽ O
    j after_draw_in_handler
draw_player_X_handler:
    li s1, ORANGE                  # Màu cam cho X
    jal draw_X                  # Gọi hàm vẽ X
after_draw_in_handler:
    jal check_win_or_draw       # Kiểm tra thắng/thua/hòa
    lw t0, game_over_flag       # Đọc cờ kết thúc trò chơi
    bne t0, zero, restore_context_handler # Nếu trò chơi kết thúc, khôi phục ngữ cảnh
    la s2, current_player       # Tải địa chỉ người chơi hiện tại
    lw s3, 0(s2)                # Đọc người chơi hiện tại
    li t0, 1                    # Kiểm tra nếu là X
    beq s3, t0, set_player_O_handler # Nếu là X, chuyển sang O
set_player_X_handler:
    li t0, 1                    # Đặt người chơi là X
    sw t0, 0(s2)                # Lưu vào current_player
    j restore_context_handler
set_player_O_handler:
    li t0, 2                    # Đặt người chơi là O
    sw t0, 0(s2)                # Lưu vào current_player
    j restore_context_handler
next_row_handler:
    slli t3, t3, 1              # Dịch trái mã quét hàng (quét hàng tiếp theo)
    li t2, MAX_ROW_SCAN_VAL     # Tải giá trị tối đa cho mã quét hàng
    bgt t3, t2, restore_context_handler # Nếu vượt quá, khôi phục ngữ cảnh
    j key_scan_loop_handler      # Quét hàng tiếp theo
restore_context_no_action:
    nop                         # Không làm gì nếu trò chơi đã kết thúc
restore_context_handler:
    lw s3, 0(sp)                # Khôi phục s3
    lw s2, 4(sp)                # Khôi phục s2
    lw t5, 8(sp)                # Khôi phục t5
    lw t3, 12(sp)               # Khôi phục t3
    lw t2, 16(sp)               # Khôi phục t2
    lw t1, 20(sp)               # Khôi phục t1
    lw a0, 24(sp)               # Khôi phục a0
    lw ra, 28(sp)               # Khôi phục ra
    addi sp, sp, 32             # Giải phóng stack
    uret                        # Trả về từ ngắt

#-------------------------------------------------------------------------------
# init_game_state:
# Mô tả: Khởi tạo trạng thái trò chơi: vẽ lưới, xóa bàn cờ, đặt người chơi đầu tiên
# Thanh ghi sử dụng: s0, s1, s2, t0
#-------------------------------------------------------------------------------
init_game_state:
    addi sp, sp, -4             # Cấp phát 4 byte trên stack
    sw ra, 0(sp)                # Lưu địa chỉ trở về
    # --- Phần 1: Vẽ lưới tĩnh màu trắng ---
    li s0, MONITOR_SCREEN        # Tải địa chỉ màn hình bitmap
    li s1, WHITE                # Màu trắng cho lưới
    #li s1, BACKGROUND          # Dùng cái này nếu muốn chỉ thấy mỗi ô màu đen ( tức là màu các đường kẻ lưới giống màu giao diện Bitmap)
    # Vẽ 4 đường ngang tại hàng 3, 7, 11, 15
    li t0, 192                  # Offset cho hàng 3 (3*64)
    jal draw_horizontal_line_segment
    li t0, 448                  # Offset cho hàng 7 (7*64)
    jal draw_horizontal_line_segment
    li t0, 704                  # Offset cho hàng 11 (11*64)
    jal draw_horizontal_line_segment
    li t0, 960                  # Offset cho hàng 15 (15*64)
    jal draw_horizontal_line_segment
    # Vẽ 4 đường dọc tại cột 3, 7, 11, 15
    li t0, 12                   # Offset cho cột 3 (3*4)
    jal draw_vertical_line_segment
    li t0, 28                   # Offset cho cột 7 (7*4)
    jal draw_vertical_line_segment
    li t0, 44                   # Offset cho cột 11 (11*4)
    jal draw_vertical_line_segment
    li t0, 60                   # Offset cho cột 15 (15*4)
    jal draw_vertical_line_segment
    # --- Phần 2: Xóa nội dung 16 ô (tô đen vùng 3x3) ---
    li s1, BLACK                # Màu đen để xóa ô
    li s0, MONITOR_SCREEN        # Tải địa chỉ màn hình
    addi s0, s0, 0            # Offset cho ô (0,0)
    jal fill_cell_3x3           # Tô đen ô
    li s0, MONITOR_SCREEN
    addi s0, s0, 16            # Offset cho ô (0,1)
    jal fill_cell_3x3
    li s0, MONITOR_SCREEN
    addi s0, s0, 32            # Offset cho ô (0,2)
    jal fill_cell_3x3
    li s0, MONITOR_SCREEN
    addi s0, s0, 48            # Offset cho ô (0,3)
    jal fill_cell_3x3
    li s0, MONITOR_SCREEN
    addi s0, s0, 256            # Offset cho ô (1,0)
    jal fill_cell_3x3
    li s0, MONITOR_SCREEN
    addi s0, s0, 272            # Offset cho ô (1,1)
    jal fill_cell_3x3
    li s0, MONITOR_SCREEN
    addi s0, s0, 288            # Offset cho ô (1,2)
    jal fill_cell_3x3
    li s0, MONITOR_SCREEN
    addi s0, s0, 304            # Offset cho ô (1,3)
    jal fill_cell_3x3
    li s0, MONITOR_SCREEN
    addi s0, s0, 512            # Offset cho ô (2,0)
    jal fill_cell_3x3
    li s0, MONITOR_SCREEN
    addi s0, s0, 528            # Offset cho ô (2,1)
    jal fill_cell_3x3
    li s0, MONITOR_SCREEN
    addi s0, s0, 544            # Offset cho ô (2,2)
    jal fill_cell_3x3
    li s0, MONITOR_SCREEN
    addi s0, s0, 560            # Offset cho ô (2,3)
    jal fill_cell_3x3
    li s0, MONITOR_SCREEN
    addi s0, s0, 768            # Offset cho ô (3,0)
    jal fill_cell_3x3
    li s0, MONITOR_SCREEN
    addi s0, s0, 784            # Offset cho ô (3,1)
    jal fill_cell_3x3
    li s0, MONITOR_SCREEN
    addi s0, s0, 800           # Offset cho ô (3,2)
    jal fill_cell_3x3
    li s0, MONITOR_SCREEN
    addi s0, s0, 816           # Offset cho ô (3,3)
    jal fill_cell_3x3
    # --- Phần 3: Reset các biến trạng thái game ---
    la s0, board_state          # Tải địa chỉ mảng trạng thái bàn cờ
    li s1, 0                    # Giá trị để xóa ô (0 = trống)
    li s2, 16                   # Số ô cần xóa (16 ô)
clear_board_loop:
    beq s2, zero, end_clear_board_loop # Nếu đã xóa hết, thoát
    sw s1, 0(s0)                # Đặt ô thành trống
    addi s0, s0, 4              # Tăng con trỏ đến ô tiếp theo
    addi s2, s2, -1             # Giảm số ô cần xóa
    j clear_board_loop
end_clear_board_loop:
    la s0, current_player       # Tải địa chỉ người chơi hiện tại
    la s1, last_winner          # Tải địa chỉ người đi đầu ván trước
    lw s2, 0(s1)                # Đọc giá trị last_winner
    beq s2, zero, set_player_X_init # Nếu là ván đầu (last_winner = 0), X đi
    li t0, 1                    # Kiểm tra nếu X đi đầu ván trước
    beq s2, t0, set_player_O    # Nếu X đi trước, O đi đầu ván này
    li t0, 2                    # Kiểm tra nếu O đi đầu ván trước
    beq s2, t0, set_player_X    # Nếu O đi trước, X đi đầu ván này
set_player_X_init:
set_player_X:
    li s1, 1                    # Đặt người chơi là X
    j set_player
set_player_O:
    li s1, 2                    # Đặt người chơi là O
set_player:
    sw s1, 0(s0)                # Lưu người chơi hiện tại
    la s0, moves_made           # Tải địa chỉ số nước đi
    sw zero, 0(s0)              # Reset số nước đi về 0
    la s0, game_over_flag       # Tải địa chỉ cờ kết thúc
    sw zero, 0(s0)              # Reset cờ kết thúc về 0
    lw ra, 0(sp)                # Khôi phục địa chỉ trở về
    addi sp, sp, 4              # Giải phóng stack
    jr ra                       # Trả về

#-------------------------------------------------------------------------------
# draw_horizontal_line_segment:
# Mô tả: Vẽ một đường ngang 16 ô màu trắng từ PHẢI sang TRÁI trên màn hình bitmap
# Args: s0 = địa chỉ màn hình (MONITOR_SCREEN), s1 = màu (WHITE), t0 = offset hàng
# Thanh ghi sử dụng: t1, t2
#-------------------------------------------------------------------------------
draw_horizontal_line_segment:
    addi sp, sp, -8             # Cấp phát 8 byte trên stack
    sw t1, 4(sp)                # Lưu t1
    sw t2, 0(sp)                # Lưu t2
    mv t1, t0                   # t1 = offset hàng (0, 256, 512, 768)
    addi t1, t1, 60             # Bắt đầu từ pixel cuối (offset + 15*4 = offset + 60)
    li t2, 16                   # Số pixel cần vẽ (16 pixel)
draw_h_loop:
    beq t2, zero, end_draw_h_loop # Nếu đã vẽ hết, thoát
    add s2, s0, t1              # s2 = MONITOR_SCREEN + offset
    sw s1, 0(s2)                # Vẽ pixel màu trắng
    addi t1, t1, -4             # Giảm offset 4 byte (di chuyển sang trái)
    addi t2, t2, -1             # Giảm số pixel cần vẽ
    j draw_h_loop
end_draw_h_loop:
    lw t2, 0(sp)                # Khôi phục t2
    lw t1, 4(sp)                # Khôi phục t1
    addi sp, sp, 8              # Giải phóng stack
    jr ra                       # Trả về

#-------------------------------------------------------------------------------
# draw_vertical_line_segment:
# Mô tả: Vẽ một đường dọc 16 pixel màu trắng từ DƯỚI lên TRÊN trên màn hình bitmap
# Args: s0 = địa chỉ màn hình (MONITOR_SCREEN), s1 = màu (WHITE), t0 = offset cột
# Thanh ghi sử dụng: t1, t2, t4
#-------------------------------------------------------------------------------
draw_vertical_line_segment:
    addi sp, sp, -12            # Cấp phát 12 byte trên stack
    sw t1, 8(sp)                # Lưu t1
    sw t2, 4(sp)                # Lưu t2
    sw t4, 0(sp)                # Lưu t4
    mv s2, t0                   # s2 = offset cột (0, 16, 32, 48, 64)
    li t2, 15                   # t2 = chỉ số hàng (bắt đầu từ hàng 15)
    li t4, 16                   # Số pixel cần vẽ (16 pixel)
draw_v_loop:
    beq t4, zero, end_draw_v_loop # Nếu đã vẽ hết, thoát
    li t1, 64                   # Mỗi hàng cách nhau 64 byte (16 pixel * 4)
    mul t1, t2, t1              # t1 = row * 64
    add t1, t1, s2              # t1 = row * 64 + offset cột
    add t1, s0, t1              # t1 = MONITOR_SCREEN + offset
    sw s1, 0(t1)                # Vẽ pixel màu trắng
    addi t2, t2, -1             # Giảm chỉ số hàng (di chuyển lên trên)
    addi t4, t4, -1             # Giảm số pixel cần vẽ
    j draw_v_loop
end_draw_v_loop:
    lw t4, 0(sp)                # Khôi phục t4
    lw t2, 4(sp)                # Khôi phục t2
    lw t1, 8(sp)                # Khôi phục t1
    addi sp, sp, 12             # Giải phóng stack
    jr ra                       # Trả về
#-------------------------------------------------------------------------------
# fill_cell_3x3:
# Mô tả: Tô màu vùng 3x3 pixel trong ô (để xóa hoặc vẽ nền)
# Args: s0 = địa chỉ bắt đầu ô, s1 = màu
#-------------------------------------------------------------------------------
fill_cell_3x3:
    sw s1, 0(s0)                # Tô pixel (0,0)
    sw s1, 4(s0)                # Tô pixel (0,1)
    sw s1, 8(s0)                # Tô pixel (0,2)
    sw s1, 64(s0)               # Tô pixel (1,0)
    sw s1, 68(s0)               # Tô pixel (1,1)
    sw s1, 72(s0)               # Tô pixel (1,2)
    sw s1, 128(s0)              # Tô pixel (2,0)
    sw s1, 132(s0)              # Tô pixel (2,1)
    sw s1, 136(s0)              # Tô pixel (2,2)
    jr ra                       # Trả về

#-------------------------------------------------------------------------------
# check_win_or_draw:
# Mô tả: Kiểm tra xem có người chơi nào thắng hoặc trò chơi hòa
# Thanh ghi sử dụng: s0, s1, s2, s3
# Trả về: a0 = 0 (chưa thắng), 1 (X thắng), 2 (O thắng), 3 (hòa)
#-------------------------------------------------------------------------------
check_win_or_draw:
    addi sp, sp, -20            # Cấp phát 20 byte trên stack
    sw ra, 16(sp)               # Lưu ra
    sw s0, 12(sp)               # Lưu s0
    sw s1, 8(sp)                # Lưu s1
    sw s2, 4(sp)                # Lưu s2
    sw s3, 0(sp)                # Lưu s3
    la s0, board_state          # Tải địa chỉ mảng trạng thái bàn cờ
    li s2, 1                    # Kiểm tra cho người chơi X
    jal check_player_win        # Gọi hàm kiểm tra thắng
    li t0, 1
    beq a0, t0, x_won_final_result_label # Nếu X thắng, nhảy đến xử lý
    li s2, 2                    # Kiểm tra cho người chơi O
    jal check_player_win
    li t0, 1
    beq a0, t0, o_won_final_result_label # Nếu O thắng, nhảy đến xử lý
    la s3, moves_made           # Tải địa chỉ số nước đi
    lw s3, 0(s3)                # Đọc số nước đi
    li t0, 16                   # Nếu đã đi 16 nước
    beq s3, t0, game_is_a_draw_final_result_label # Hòa
    li a0, 0                    # Chưa có kết quả
    j end_of_check_win_processing_label
x_won_final_result_label:
    li a0, 1                    # X thắng
    j call_game_end_processing_logic_label
o_won_final_result_label:
    li a0, 2                    # O thắng
    j call_game_end_processing_logic_label
game_is_a_draw_final_result_label:
    li a0, 3                    # Hòa
call_game_end_processing_logic_label:
    addi sp, sp, -4             # Cấp phát 4 byte trên stack
    sw a0, 0(sp)                # Lưu kết quả (a0)
    la s0, game_over_flag       # Tải địa chỉ cờ kết thúc
    li s1, 1                    # Đặt cờ kết thúc = 1
    sw s1, 0(s0)                # Lưu cờ kết thúc
    # Lưu người đi đầu ván này vào last_winner
    la s0, last_winner          # Tải địa chỉ last_winner
    la s1, current_player       # Tải địa chỉ người chơi hiện tại
    lw s2, 0(s1)                # Đọc người chơi hiện tại
    sw s2, 0(s0)                # Lưu vào last_winner
    lw a0, 0(sp)                # Khôi phục kết quả
    li t0, 1
    beq a0, t0, print_x_wins_msg_final_label # Nếu X thắng
    li t0, 2
    beq a0, t0, print_o_wins_msg_final_label # Nếu O thắng
    la a0, msg_draw             # Tải thông báo hòa
    li a7, 4                    # Syscall 4: In chuỗi
    ecall
    la s0, draw_count           # Tải địa chỉ số lần hòa
    lw s1, 0(s0)                # Đọc số lần hòa
    addi s1, s1, 1              # Tăng số lần hòa
    sw s1, 0(s0)                # Lưu số lần hòa
    j print_scores_at_end_label
print_x_wins_msg_final_label:
    la a0, msg_X_wins           # Tải thông báo X thắng
    li a7, 4                    # Syscall 4: In chuỗi
    ecall
    la s0, score_X              # Tải địa chỉ điểm X
    lw s1, 0(s0)                # Đọc điểm X
    addi s1, s1, 1              # Tăng điểm X
    sw s1, 0(s0)                # Lưu điểm X
    j print_scores_at_end_label
print_o_wins_msg_final_label:
    la a0, msg_O_wins           # Tải thông báo O thắng
    li a7, 4                    # Syscall 4: In chuỗi
    ecall
    la s0, score_O              # Tải địa chỉ điểm O
    lw s1, 0(s0)                # Đọc điểm O
    addi s1, s1, 1              # Tăng điểm O
    sw s1, 0(s0)                # Lưu điểm O
print_scores_at_end_label:
    la a0, msg_score_is         # Tải chuỗi "Score: X - "
    li a7, 4                    # Syscall 4: In chuỗi
    ecall
    lw a0, score_X              # Tải điểm X
    li a7, 1                    # Syscall 1: In số nguyên
    ecall
    la a0, space_char           # Tải ký tự khoảng trắng
    li a7, 4                    # Syscall 4: In chuỗi
    ecall
    la a0, msg_draw_sep         # Tải chuỗi " | Draw - "
    li a7, 4
    ecall
    lw a0, draw_count           # Tải số lần hòa
    li a7, 1                    # Syscall 1: In số nguyên
    ecall
    la a0, space_char           # Tải ký tự khoảng trắng
    li a7, 4                    # Syscall 4: In chuỗi
    ecall
    la a0, msg_O_score_sep      # Tải chuỗi " | O - "
    li a7, 4
    ecall
    lw a0, score_O              # Tải điểm O
    li a7, 1                    # Syscall 1: In số nguyên
    ecall
    la a0, newline              # Tải ký tự xuống dòng
    li a7, 4                    # Syscall 4: In chuỗi
    ecall
    addi sp, sp, 4              # Giải phóng stack
reset_game_after_print:
    jal init_game_state         # Reset trò chơi cho ván mới
    j restore_context_handler   # Khôi phục ngữ cảnh
end_of_check_win_processing_label:
    lw s3, 0(sp)                # Khôi phục s3
    lw s2, 4(sp)                # Khôi phục s2
    lw s1, 8(sp)                # Khôi phục s1
    lw s0, 12(sp)               # Khôi phục s0
    lw ra, 16(sp)               # Khôi phục ra
    addi sp, sp, 20             # Giải phóng stack
    jr ra                       # Trả về

#-------------------------------------------------------------------------------
# check_player_win:
# Mô tả: Kiểm tra xem người chơi có thắng không (4 ô liên tiếp)
# Args: s0 = địa chỉ board_state, s2 = người chơi (1 = X, 2 = O)
# Trả về: a0 = 0 (không thắng), 1 (thắng)
# Thanh ghi sử dụng: t0, t1, t2, t3, t4, t5
#-------------------------------------------------------------------------------
check_player_win:
    # Kiểm tra 4 hàng
    li t3, 0                    # Khởi tạo chỉ số hàng
check_rows:
    slli t0, t3, 4              # t0 = row * 16 (offset hàng)
    add t0, s0, t0              # t0 = địa chỉ ô đầu hàng
    lw t1, 0(t0)                # Đọc ô 0
    lw t2, 4(t0)                # Đọc ô 1
    lw t4, 8(t0)                # Đọc ô 2
    lw t5, 12(t0)               # Đọc ô 3
    beq t1, s2, check_row_1     # Nếu ô 0 = người chơi
    j next_row
check_row_1:
    beq t2, s2, check_row_2     # Nếu ô 1 = người chơi
    j next_row
check_row_2:
    beq t4, s2, check_row_3     # Nếu ô 2 = người chơi
    j next_row
check_row_3:
    beq t5, s2, cpw_win_return  # Nếu ô 3 = người chơi, thắng
next_row:
    addi t3, t3, 1              # Tăng chỉ số hàng
    li t4, 4                    # Số hàng = 4
    blt t3, t4, check_rows      # Nếu chưa hết hàng, tiếp tục
    # Kiểm tra 4 cột
    li t3, 0                    # Khởi tạo chỉ số cột
check_columns:
    slli t0, t3, 2              # t0 = col * 4 (offset cột)
    add t0, s0, t0              # t0 = địa chỉ ô đầu cột
    lw t1, 0(t0)                # Đọc ô 0
    lw t2, 16(t0)               # Đọc ô 4
    lw t4, 32(t0)               # Đọc ô 8
    lw t5, 48(t0)               # Đọc ô 12
    beq t1, s2, check_col_1     # Nếu ô 0 = người chơi
    j next_col
check_col_1:
    beq t2, s2, check_col_2     # Nếu ô 4 = người chơi
    j next_col
check_col_2:
    beq t4, s2, check_col_3     # Nếu ô 8 = người chơi
    j next_col
check_col_3:
    beq t5, s2, cpw_win_return  # Nếu ô 12 = người chơi, thắng
next_col:
    addi t3, t3, 1              # Tăng chỉ số cột
    li t4, 4                    # Số cột = 4
    blt t3, t4, check_columns   # Nếu chưa hết cột, tiếp tục
    # Kiểm tra đường chéo chính (0,0 -> 3,3)
    lw t1, 0(s0)                # Đọc ô (0,0)
    lw t2, 20(s0)               # Đọc ô (1,1)
    lw t4, 40(s0)               # Đọc ô (2,2)
    lw t5, 60(s0)               # Đọc ô (3,3)
    beq t1, s2, check_diag1_1   # Nếu ô (0,0) = người chơi
    j check_diag2
check_diag1_1:
    beq t2, s2, check_diag1_2   # Nếu ô (1,1) = người chơi
    j check_diag2
check_diag1_2:
    beq t4, s2, check_diag1_3   # Nếu ô (2,2) = người chơi
    j check_diag2
check_diag1_3:
    beq t5, s2, cpw_win_return  # Nếu ô (3,3) = người chơi, thắng
check_diag2:
    # Kiểm tra đường chéo phụ (0,3 -> 3,0)
    lw t1, 12(s0)               # Đọc ô (0,3)
    lw t2, 24(s0)               # Đọc ô (1,2)
    lw t4, 36(s0)               # Đọc ô (2,1)
    lw t5, 48(s0)               # Đọc ô (3,0)
    beq t1, s2, check_diag2_1   # Nếu ô (0,3) = người chơi
    j cpw_no_win_return
check_diag2_1:
    beq t2, s2, check_diag2_2   # Nếu ô (1,2) = người chơi
    j cpw_no_win_return
check_diag2_2:
    beq t4, s2, check_diag2_3   # Nếu ô (2,1) = người chơi
    j cpw_no_win_return
check_diag2_3:
    beq t5, s2, cpw_win_return  # Nếu ô (3,0) = người chơi, thắng
cpw_no_win_return:
    li a0, 0                    # Không thắng
    jr ra
cpw_win_return:
    li a0, 1                    # Thắng
    jr ra

#-------------------------------------------------------------------------------
# draw_X:
# Mô tả: Vẽ ký hiệu X (màu cam) trong ô 3x3
# Args: s0 = địa chỉ bắt đầu ô, s1 = màu (ORANGE)
#-------------------------------------------------------------------------------
draw_X:
    sw s1, 0(s0)                # Tô pixel (0,0)
    sw s1, 68(s0)               # Tô pixel (1,1)
    sw s1, 136(s0)              # Tô pixel (2,2)
    sw s1, 8(s0)                # Tô pixel (0,2)
    sw s1, 128(s0)              # Tô pixel (2,0)
    jr ra                       # Trả về

#-------------------------------------------------------------------------------
# draw_O:
# Mô tả: Vẽ ký hiệu O (màu xanh dương) trong ô 3x3
# Args: s0 = địa chỉ bắt đầu ô, s1 = màu (BLUE)
#-------------------------------------------------------------------------------
draw_O:
    sw s1, 4(s0)                # Tô pixel (0,1)
    sw s1, 64(s0)               # Tô pixel (1,0)
    sw s1, 72(s0)               # Tô pixel (1,2)
    sw s1, 132(s0)              # Tô pixel (2,1)
    jr ra                       # Trả về
