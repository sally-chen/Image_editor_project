.equ ADDR_PS2, 0xFF200100
.equ ADDR_VGA, 0x08000000
.equ STACK, 0x04000000
 .data
 #reserve enough for 2*320*240 = 153600 halfwords of data
 BackBuffer:
 .skip 246400
 Buffer:
 .skip 153600
 #mouse picture
 Mouse:
.byte 0
.byte -1
.byte -1
.byte -1
.byte -1
.byte -1
.byte -1
.byte -1    
.byte 0
.byte 0 
.byte -1
.byte -1
.byte -1
.byte -1
.byte -1
.byte -1
.byte 0
.byte 1
.byte 0
.byte -1
.byte -1
.byte -1
.byte -1
.byte -1
.byte 0
.byte 1
.byte 1
.byte 0
.byte -1
.byte -1
.byte -1
.byte -1
.byte 0
.byte 1
.byte 1
.byte 1
.byte 0
.byte -1
.byte -1
.byte -1
.byte 0
.byte 1
.byte 1
.byte 1
.byte 1
.byte 0
.byte -1
.byte -1
.byte 0
.byte 1
.byte 1 
.byte 1
.byte 1
.byte 1
.byte 0
.byte -1
.byte 0
.byte 1
.byte 1 
.byte 1
.byte 1
.byte 0
.byte 0
.byte 0
.byte 0
.byte 1
.byte 1
.byte 1
.byte 0
.byte -1
.byte -1
.byte -1
.byte 0
.byte 0
.byte 0
.byte 1
.byte 0
.byte -1
.byte -1
.byte -1
.byte 0
.byte -1
.byte 0
.byte 1
.byte 0
.byte -1
.byte -1
.byte -1
.byte -1
.byte -1
.byte -1
.byte 0
.byte 1
.byte 0
.byte -1
.byte -1
.byte -1
.byte -1
.byte -1
.byte -1
.byte 0
.byte 1
.byte 0
.byte -1
.byte -1
.byte -1
.byte -1
.byte -1
.byte 0
.byte 1
.byte 0
.byte -1
.byte -1
.byte -1
.byte -1
.byte -1
.byte -1
.byte 0
.byte -1
.byte -1
 
 #put button coords here
 
myfile:
.incbin "duck.bmp"

blackAndWhite:
.incbin "BandW.bmp"
Contrast:
.incbin "contrast.bmp"
Brighten:
.incbin "brighten.bmp"

positionBW:
.word 0
.word 0 
.word 19 
.word 19
positionContrast:
.word 0 
.word 19 
.word 19
.word 39
positionBrighten:
.word 0 
.word 39 
.word 19 
.word 59
#to keep track of mouse position
 MousePosition:
 .skip 8
 GlobalDraw:
 .skip 1
 .text
 .global _start
 _start:
 #irq line 7
 movia r3, 0xFF203024
 movia r4, BackBuffer
 stwio r4, 0(r3)
 movia r3, GlobalDraw
 stb r0, 0(r3)
 
 movia sp, STACK
 movia r10, MousePosition
 movi r9, 120
 sth r9, 0(r10)
 movi r9, 160
 sth r9, 4(r10)
 
 movi r6, 0 #mode passed to load buffer
 call load_buffer
 
 call draw_buffer
 call draw_mouse

 call drawButtons
  call InitMouse
 loop:
 br loop

 
.global InitMouse
 InitMouse:
 movia r10, ADDR_PS2
 #set bit 0 to enable controls
 movi r11, 0b1
 stwio r11, 4(r10)

 
movia r10, ADDR_PS2
movi r11, 0xF4
stw r11, 0(r10)
movi r12, 0xFA
whileLoop:
ldwio r11, 0(r10)
bne r12, r11, whileLoop
 movi r10, 0b10000000
 movi r11, 0b01
 wrctl ctl3, r10
 wrctl ctl0, r11
 ret
 
.global draw_buffer
draw_buffer:
movia r11, 0xFF203024
ldw r16, 0(r11)
movia r17, Buffer

#go past header

movi r21, 240
movi r11, 0
Loop:
movi r19, 320
movi r9, 0
Loop2:
#print out 1 pixel location = x*2 + 1024*y
ldw r20, 0(r17)
#multiply 2*r9
muli r8, r9, 2
muli r7, r11, 1024
add r7, r7, r8
#add this value to r16
add r16, r16, r7
stwio r20, 0(r16)
#subtract it
sub r16, r16, r7
addi r17, r17, 4

addi r9, r9, 2
bne r9, r19, Loop2

addi r11, r11, 1
bne r21, r11, Loop
 #stuff here
ret

 .global load_buffer
 load_buffer:
 movia r8, Buffer
 movia r9, myfile
 addi r9, r9, 70

 movi r11, 240
 Loop3:
  movi r12, 320
 movi r10, 0
 Loop4:
#print out 1 pixel location = x*2 + 1024*y
ldh r13, 0(r9)

 #process image, if mode is 0 then original image
 subi sp, sp, 28
 stw r13, 24(sp)
 stw ra, 20(sp)
 stw r8, 16(sp)
 stw r9, 12(sp)
 stw r10, 8(sp)
 stw r11, 4(sp)
 stw r12, 0(sp)

 movi r2, 1
 beq r6, r2, BW_mode
 movi r2, 2
 beq r6, r2, Brighten_mode
 movi r2, 3
 beq r6, r2, Contrast_mode



 Buffer_Back:
 ldw r13, 24(sp)
 ldw ra, 20(sp)
 ldw r8, 16(sp)
 ldw r9, 12(sp)
 ldw r10, 8(sp)
 ldw r11, 4(sp)
 ldw r12, 0(sp)
 sthio r13, 0(r8)
 addi sp, sp, 28
 #subtract it
 addi r8, r8, 2
 addi r9, r9, 2

 addi r10, r10, 1
 bne r10, r12, Loop4

 subi r11, r11, 1
 bne r11, r0, Loop3
 ret

 BW_mode:
   mov r4,r13

   mov r13,r2
   br Buffer_Back

 Brighten_mode:
   #process image
   mov r4,r13
   movi r5, 6

  mov r13,r2
   br Buffer_Back

 Contrast_mode:
   mov r4,r13
   movi r5, 3 

   mov r13,r2
   br Buffer_Back
  
 
.global draw_mouse
draw_mouse:
movia r16, 0xFF203024
ldw r11, 0(r16)
 movia r10, MousePosition
 movia r20, Mouse
#load y position
ldw r9, 0(r10)
#load x position
ldw r8, 4(r10)
movi r15, 15
movi r16, 8


movi r19, 0
loopMouse1:
movi r21, 0
loopMouse2:
ldb r13, 0(r20)
#get location
muli r17, r9, 1024
muli r18, r8, 2
add r17, r17, r18
add r11, r11, r17

bgt r13, r0, drawWhite
beq r13, r0, drawBlack
blt r13, r0, drawBlank


drawWhite:
movia r13, 0xFFFF
sthio r13, 0(r11)
br drawBlank
drawBlack:
sthio r0, 0(r11)
br drawBlank
drawBlank:



sub r11, r11, r17
addi r21, r21, 1
addi r8, r8, 1
addi r20, r20, 1
bne r21, r16, loopMouse2
addi r19, r19, 1
addi r9, r9, 1
ldw r8, 4(r10)
bne r19, r15, loopMouse1

ret

.global drawButtons
drawButtons:
movia r11, 0xFF203024
ldw r16, 0(r11)
movia r11, blackAndWhite

addi r11, r11, 70

movia r18, Contrast
addi r18, r18, 70

movia r19, Brighten
addi r19, r19, 70

movi r12, 80
movi r8, 60
movi r13, 20
LoopBW:
movi r9, 0
LoopBW2:
#print out 1 pixel location = x*2 + 1024*y
ldw r20, 0(r11)
#multiply 2*r9
muli r6, r9, 2
muli r7, r8, 1024
add r7, r7, r6
#add this value to r16
add r16, r16, r7
stwio r20, 0(r16)
#subtract it
sub r16, r16, r7
addi r11, r11, 4

ldw r20, 0(r18)
#multiply 2*r9
addi r8, r8, 22
muli r6, r9, 2
muli r7, r8, 1024
add r7, r7, r6
#add this value to r16
add r16, r16, r7
stwio r20, 0(r16)
#subtract it
sub r16, r16, r7
addi r18, r18, 4
subi r8, r8, 22

ldw r20, 0(r19)
#multiply 2*r9
addi r8, r8, 42
muli r6, r9, 2
muli r7, r8, 1024
add r7, r7, r6
#add this value to r16
add r16, r16, r7
stwio r20, 0(r16)
#subtract it
sub r16, r16, r7
addi r19, r19, 4
subi r8, r8, 42

addi r9, r9, 2
bne r9, r13, LoopBW2

addi r8, r8, 1
bne r12, r8, LoopBW


ret

 .section .exceptions, "ax"
 .align 2
 handler:
 subi sp, sp, 4
 stw ea, 0(sp)
	
 movia r3, GlobalDraw
 ldb r21, 0(r3)
 bne r21, r0, done
 
 nextOne:
 #poll status register
 movia r19, 0xFF20302C
ldw r18, 0(r19)
andi r2, r18, 0b1
#if not 0, swap is not finished
bne r2, r0, nextOne
movi r2, 1
stb r2, 0(r3)
call draw_buffer
call drawButtons
call draw_mouse

movi r2, 1
movia r19, 0xFF203020

stwio r2, 0(r19)

 movia r10, ADDR_PS2 
 movia r13, MousePosition
 ldw r11, 4(r10)
 #check for errors - bit 10
 andi r11, r11, 0x100
 beq r11, r0, done
 
 #get data first packet -> overflow etc, will handle later
 ldw r11, 0(r10)
 #check data is valid - bit 15
 andi r12, r11, 0x8000
 beq r12, r0, done
 andi r12, r11, 0b1
 
 andi r7, r11, 0b100000
 andi r8, r11, 0b10000
 
 
 #store x and y movement
 
 ldb r11, 0(r10)
 ldw r14, 4(r13)
 beq r8, r0, add
 br subt
 add:
 add r11, r11, r14
 br checkBounds
 subt:
 add r11, r14, r11
 
 checkBounds:
 movi r14, 312
 blt r11, r0, setZero
 bgt r11, r14, setHigh
 stw r11, 4(r13)
 br Ymov
 
 setZero:
 stw r0, 4(r13)
 br Ymov
 setHigh:
 stw r14, 4(r13)
 br Ymov
 

 Ymov:
 
 ldb r11, 0(r10)
 ldw r14, 0(r13)
 beq r7, r0, add1
 br subt1
 
 add1:
 sub r11, r14, r11
 br checkBounds2
 subt1:
 sub r11, r14, r11
 
 checkBounds2:
 movi r14, 225
 blt r11, r0, setZero2
 bgt r11, r14, setHigh2
 stw r11, 0(r13)
 br filterIt
 
 setZero2:
 stw r0, 0(r13)
 br filterIt
 setHigh2:
 stw r14, 0(r13)
 br filterIt

 

filterIt:



  beq r12, r0, reset
  #y position
 ldw r12, 0(r13)
  #x position
 ldw r14, 4(r13)

 #check if within button bounds
 movi r15, 19
 bgt r14, r15, reset
 movi r15, 120
 bgt r12, r15, reset
 movi r15, 60
 blt r12, r15, reset
 
 
 movi r15, 100
 bgt r12, r15, bright

 movi r15, 80
 blt r12, r15, greyscale
 
 br contrast1
 greyscale:
 movi r6, 1
 call load_buffer
 call draw_buffer
 br reset
 bright:
 movi r6, 2
 call load_buffer
call draw_buffer
 br reset
 contrast1:
 movi r6, 3
 call load_buffer
 call draw_buffer
 br reset

reset:
 movia r3, GlobalDraw
 stb r0, 0(r3)
 done:
  ldw ea, 0(sp)
  addi sp, sp, 4
 subi ea, ea, 4
 
eret