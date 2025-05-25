.eqv IN_ADDRESS_HEXA_KEYBOARD       0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD      0xFFFF0014
.text 
main:             
li  t1, IN_ADDRESS_HEXA_KEYBOARD 
li  t2, OUT_ADDRESS_HEXA_KEYBOARD 
li  t3, 0x08        

polling:          
sb  t3, 0(t1 )      

lb  a0, 0(t2)       

print:        
li  a7, 34          

ecall 
sleep:        
li  a0, 100         

li  a7, 32 
ecall        
back_to_polling:  
j     polling       
