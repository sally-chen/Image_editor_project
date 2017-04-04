.equ ADDR_PS2, 0xFF200100
.equ ADDR_VGA, 0x08000000
 .data
 #reserve enough for 2*320*240 = 153600 halfwords of data
 Buffer:
 .skip 153600
 #mouse picture
 Mouse: .byte 0 .byte -1 .byte -1 .byte -1 .byte -1 .byte -1 .byte -1 .byte -1
        .byte 0 .byte 0  .byte -1 .byte -1 .byte -1 .byte -1 .byte -1 .byte -1
		.byte 0 .byte 1 .byte 0 .byte -1 .byte -1 .byte -1 .byte -1 .byte -1
		.byte 0 .byte 1 .byte 1 .byte 0 .byte -1 .byte -1 .byte -1 .byte -1
		.byte 0 .byte 1 .byte 1 .byte 1 .byte 0 .byte -1 .byte -1 .byte -1
		.byte 0 .byte 1 .byte 1 .byte 1 .byte 1 .byte 0 .byte -1 .byte -1
		.byte 0 .byte 1 .byte 1  .byte 1 .byte 1 .byte 1 .byte 0 .byte -1
		.byte 0 .byte 1 .byte 1  .byte 1 .byte 1 .byte 0 .byte 0 .byte 0
		.byte 0 .byte 1 .byte 1 .byte 1 .byte 0 .byte -1 .byte -1 .byte -1
		.byte 0 .byte 0 .byte 0 .byte 1 .byte 0 .byte -1 .byte -1 .byte -1
		.byte 0 .byte -1 .byte 0 .byte 1 .byte 0 .byte -1 .byte -1 .byte -1
		.byte -1 .byte -1 .byte -1 .byte 0 .byte 1 .byte 0 .byte -1 .byte -1
		.byte -1 .byte -1 .byte -1 .byte -1 .byte 0 .byte 1 .byte 0 .byte -1
		.byte -1 .byte -1 .byte -1 .byte -1 .byte 0 .byte 1 .byte 0 .byte -1
		.byte -1 .byte -1 .byte -1 .byte -1 .byte -1 .byte 0 .byte -1 .byte -1
 
 #put button coords here
 
myfile:
.incbin "duck.bmp"
#to keep track of mouse position
 MousePosition:
 .skip 8
 
 .text
 .global _start
 _start:
 #irq line 7
 call InitMouse

 
 
 movia r10, MousePosition
 movi r9, 120
 movi r8, 160
 sth r9, 0(r10)
 sth r8, 2(r10)
 
 call load_buffer
 loop:
 br loop
 
 InitMouse:
 movia r10, ADDR_PS2
 #set bit 0 to enable controls
 movi r11, 0b1
 stwio r11, 4(r10)
 movi r10 0b1000000
 movi r11 0b01
 wrctl ctl3, r10
 wrctl ctl0, r11
 
 ret
 
drawBuffer:

ret
 
 .section .exceptions, "ax"
 .align 2
 handler:
 subi sp, sp, 4
 stw ea, 0(sp)
 movia r10, 0xFF200100 
 movia r13, MousePosition
 ldw r11, 4(r10)
 #check for errors - bit 10
 andi r11, r11, 0x400
 bne r11, r0, done
 
 #get data first packet -> overflow etc, will handle later
 ldw r11, 0(r10)
 #check data is valid - bit 15
 andi r12, r11, 0x8000
 bne r12, r0, done
 
 #store x and y movement
 ldw r11, 0(r10)
 ldh r14, 0(r13)
 add r11, r11, r14
 sth r11, 0(r13)
 
 ldw r11, 0(r10)
 ldh r14, 2(r13)
 add r11, r11, r14
 sth r11, 2(r13)
 
 call draw_buffer
 call draw_mouse
 
 done:
  ldw ea, 0(sp)
  addi sp, sp, 4
 subi ea, ea, 4
 eret
 

draw_buffer:
 movia r16, ADDR_VGA
movia r17, Buffer
#go past header

movi r21, 240
movi r11, 0
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

addi r11, r11, 1
bne r21, r11, Loop
 #stuff here
ret


load_buffer:
movia r16, Buffer
movia r17, myfile
addi r17, r17, 70

movi r21, 240
Loop:
movi r19, 320
movi r9, 0
Loop2:
#print out 1 pixel location = x*2 + 1024*y
ldh r20, 0(r17)
#multiply 2*r9
#add this value to r16


sthio r20, 0(r16)
#subtract it
addi r20, r20, 2
addi r17, r17, 2

addi r9, r9, 1
bne r9, r19, Loop2

subi r21, r21, 1
bne r21, r0, Loop

ret

draw_mouse:
movia r11, ADDR_VGA
 movia r10, MousePosition
 movia r20, Mouse
#load y position
ldh r9, 0(r10)
#load x position
ldh r8, 0(r10)
movi r15, 15
movi r16, 8


movi r19, 0
loopMouse1:
movi r18, 0
loopMouse2:
ldb r13, 0(r20)
#get location
bgt r13, r0, drawWhite
beq r13, r0, drawBlack
blt r13, r0, drawBlank

muli r17, r9, 1024
muli r18, r8, 2
add r17, r17, r18
add r11, r11, r17

drawWhite:
movi r13, 0xFFFF
ldh r13, 0(r11)
br drawBlank
drawBlack:
ldh r0, 0(r11)
br drawBlank
drawBlank:



sub r11, r11, r17
addi r18, r18, 1
addi r8, r8 1
bne r18, r16, loopMouse2
addi r19, r19, 1
addi r9, r9, 1
bne r19, r15, loopMouse1

ret
 