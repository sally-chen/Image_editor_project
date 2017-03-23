.equ ADDR_VGA, 0x08000000

 .data
 #reserve enough for 360*240 = 86400*2 = 172800 halfwords of data
myfile:
.incbin "duck.bmp"
 
 .text
 .global _start
 _start:
 movia r16, ADDR_VGA
movia r17, myfile
#go past header
addi r17, r17, 70
movi r21, 240
Loop:
movi r19, 320
movi r9, 0
Loop2:
#print out 1 pixel location = x*2 + 1024*y
ldh r20, 0(r17)
#multiply 2*r9
muli r8, r9, 2
muli r7, r21, 1024
add r7, r7, r8
#add this value to r16
add r16, r16, r7
sthio r20, 0(r16)
#subtract it
sub r16, r16, r7
addi r17, r17, 2

addi r9, r9, 1
bne r9, r19, Loop2

subi r21, r21, 1
bne r21, r0, Loop
 #stuff here
loop:
br loop
 
