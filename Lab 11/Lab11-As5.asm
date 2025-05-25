.data 
	message: .asciz "Exception occurred.\n" 
.text 
main: 
try: 
	la t0, catch
	csrrw zero, utvec, t0
	csrrsi zero, ustatus, 1

	lw zero, 0
finally: 
	li a7, 10
	ecall
	
catch:
	li  a7, 4
	la  a0, message
	ecall

	la  t0, finally
	csrrw zero, uepc, t0
	uret