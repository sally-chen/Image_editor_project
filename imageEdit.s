filter_blur:
#row 0
.byte 0,0,1,0,0
#row 1
.byte 0,1,1,1,0
#row 2
.byte 1,1,1,1,1
#row 3
.byte 0,1,1,1,0
#row 4
.byte 0,0,1,0,0



.global grayscale
#pixel info is passed in as r4, 2 bytes (1)
grayscale:
  subi sp,sp,16
  stw  r16, 0(sp)
  stw  r17, 4(sp)
  stw  r18, 8(sp)
  stw  r19, 12(sp)
  
  #r16 B
  andi r16, r4, 0x001F
  muli r16, r16,3
  #r17 G
  srli r17,r4, 5
  andi r17, r17, 0x003F
  muli r17, r17,6
  #r18 R
  srli r18, r4, 11
  andi r18, r18, 0x001F
  muli r18, r18,4
  
  #add rgb and average by dividing by 3
  add r19, r16, r17
  add r19, r18, r19
  movi r2, 14
  divu r19, r19, r2
  
  movi r2, 31
  bgt r19, r2, TooDark
  #concaternate-> r19r19r19
Back:
  mov r2,r19
  slli r2, r2, 5
  or r2,r19,r2
  slli r2,r2, 6
   or r2,r19,r2
 
  ldw  r16, 0(sp)
  ldw  r17, 4(sp)
  ldw  r18, 8(sp)
  ldw  r19, 12(sp)
  addi sp,sp,16

	
  #return r2, 16 bits
  ret

TooDark:
  movi r19,31
  br Back
  
#pixel info is passed in as r4, 2 bytes (1)
#how much brightness is in r5
.global brighten
brighten:
  subi sp,sp,32
  stw ra, 0(sp)
  stw r4, 4(sp)
  stw r5, 8(sp)
  stw  r16, 12(sp)
  stw  r17, 16(sp)
  stw  r18, 20(sp)
  stw  r19,24(sp)
  stw  r20,28(sp)

  mov r19,r4
  mov r20,r5
  
   #r16 B
  andi r16, r19, 0x001F
  add r16, r16, r20
  
  mov r4,r16
  movi r5, 31
  call checkbound 
  mov r16,r4
  
  
  #r17 G
  srli r17,r19, 5
  andi r17, r17, 0x003F
  add  r17, r17,r20
  
  mov r4,r17
  movi r5, 63
  call checkbound 
  mov r17,r4
  
  
  #r18 R
  srli r18, r19, 11
  andi r18, r18, 0x001F
  add  r18, r18, r20
  
  mov r4,r18
  movi r5, 31
  call checkbound 
  mov r18,r4
  
  #concaternate-> r19r19r19
  mov r2,r18
  slli r2,r2, 6
  or r2,r17,r2
  slli r2,r2, 5
  or r2,r16,r2
   
   
  ldw ra, 0(sp)
  ldw r4, 4(sp)
  ldw r5, 8(sp)
  ldw  r16, 12(sp)
  ldw  r17, 16(sp)
  ldw  r18, 20(sp)
  ldw  r19,24(sp)
  ldw  r20,28(sp)
  addi sp,sp,32
  
 ret
 
 
.global checkbound
checkbound:
  blt r4, r0, lessThanZero
  bgt r4,r5, higherThanBound  
 
 retu:
 ret
  
  lessThanZero:
  movi r4, 0 
  br retu
  
  higherThanBound:
  mov r4,r5
  br retu 
  
#r4 pixel value, r5 degree of contrast being added
#f(x)=α(x−128)+128+b 
.global contrast
contrast:

  subi sp,sp,16
  stw  r16, 0(sp)
  stw  r17, 4(sp)
  stw  r18, 8(sp)
  stw  r19, 12(sp)
  
  #r16 B
  andi r16, r4, 0x001F
  subi r16, r16, 32
  mul r16, r16,r5
  addi r16, r16, 32
  
  #r17 G
  srli r17,r4, 5
  andi r17, r17, 0x003F
  subi r17, r17, 64
  mul r17, r17,r5
  addi r17, r17, 64
  
  #r18 R
  srli r18, r4, 11
  andi r18, r18, 0x001F
  subi r18, r18, 32
  mul r18, r18,r5
  addi r18, r18, 32
  
  mov r2,r18
  slli r2,r2, 6
  or r2,r17,r2
  slli r2,r2, 5
  or r2,r16,r2
  
  ldw  r16, 0(sp)
  ldw  r17, 4(sp)
  ldw  r18, 8(sp)
  ldw  r19, 12(sp)
  addi sp,sp,16
  
  ret
  
  
#r9 is the current location---------------------------filter------------------------------------------------------
#r4 is   
.global filter
filter:

#save ra, r23-r13,
subi sp,sp,48
stw  ra, 0(sp)
stw  r13, 4(sp)
stw  r14, 8(sp)
stw  r15, 12(sp)
stw  r16, 16(sp)
stw  r17, 20(sp)
stw  r18, 24(sp)
stw  r19, 28(sp)
stw  r20, 32(sp)
stw  r21, 36(sp)
stw  r22, 40(sp)
stw  r23, 44(sp)
  
movia r21, filter_blur
#initialize r20
movi r20, 0 #b
movi r19, 0 #g
movi r18, 0 #r

#r4-> left top position of image sample corresponding to filter matrix
subi r4,r5,1284


#counter outside
movi r22, 5
LoopY:
#counter inside
movi r23, 5

LoopX: 
#read from filter
ldb r17,0(r21)
#read from pixel
ldh r16, 0(r4)
#-------------how do you wrap around...?

#extract r,g,b value from pixel, multiply and sum 
#r15 B
andi r15, r4, 0x001F
mul r15, r15, r17
add r20,r20,r15
#r14 G
srli r14,r4, 5
andi r14, r14, 0x003F
mul r14, r14, r17
add r19,r19,r14
#r13 R
srli r13, r4, 11
andi r13, r13, 0x001F
mul r13, r13, r17
add r18,r18,r13

#increment filter pointer
addi r21, r21, 1
#increment image sample pointer
addi r4, r4, 2

#decrement inside loop counter
subi r23, r23,1
bgt r23,r0, LoopX

addi r4, r4, 632
subi r22, r22,1
bgt r22,r0, LoopY

#divide each pixel value by total of filter value
movi r2, 13
divu r20, r20, r2
divu r19, r19, r2
divu r18, r18, r2

#check bound
mov r4,r20
movi r5, 31
call checkbound 
mov r20,r4

mov r4,r19
movi r5, 63
call checkbound 
mov r19,r4

mov r4,r18
movi r5, 31
call checkbound 
mov r18,r4

#concaternate
mov r2,r18
slli r2,r2, 6
or r2,r19,r2
slli r2,r2, 5
or r2,r20,r2


ldw  ra, 0(sp)
ldw  r13, 4(sp)
ldw  r14, 8(sp)
ldw  r15, 12(sp)
ldw  r16, 16(sp)
ldw  r17, 20(sp)
ldw  r18, 24(sp)
ldw  r19, 28(sp)
ldw  r20, 32(sp)
ldw  r21, 36(sp)
ldw  r22, 40(sp)
ldw  r23, 44(sp)
addi sp,sp,48

ret