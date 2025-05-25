.eqv MONITOR_SCREEN 0x10010000
.eqv RED 0x00FF0000
.eqv GREEN 0x0000FF00
.eqv BLUE 0x000000FF
.eqv WHITE 0x00FFFFFF
.eqv YELLOW 0x00FFFF00

.text
	li a0, MONITOR_SCREEN
	
	li t0, RED
	sw t0, 0(a0)
	
	li t0, GREEN
	sw t0, 4(a0)
	
	li t0, BLUE
	sw t0, 8(a0)
	
	li t0, WHITE
	sw t0, 12(a0)
	
	li t0, YELLOW
	sw t0, 32(a0)
	
	li t0, WHITE
	lb t0, 42(a0)