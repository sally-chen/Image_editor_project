
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
  muli r17, r17,3
  #r18 R
  srli r18, r4, 11
  andi r18, r18, 0x001F
  muli r18, r18,3
  
  #add rgb and average by dividing by 3
  add r19, r16, r17
  add r19, r18
  movi r2, 3
  divu r19, r19, r2
  
  #concaternate-> r19r19r19
  mov r2,r19
  slli r2, 6
  or r2,r19,r2
  slli r2, 5
   or r2,r19,r2
 
  ldw  r16, 0(sp)
  ldw  r17, 4(sp)
  ldw  r18, 8(sp)
  ldw  r19, 12(sp)
  addi sp,sp,16
  
  #return r2, 16 bits
  ret
  
#pixel info is passed in as r4, 2 bytes (1)
#how much brightness is in r5
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
  addi r16, r16, r20
  
  mov r4,r16
  mov r5, 32
  call checkbound 
  mov r16,r4
  
  
  #r17 G
  srli r17,r19, 5
  andi r17, r17, 0x003F
  add  r17, r17,r20
  
  mov r4,r17
  mov r5, 64
  call checkbound 
  mov r17,r4
  
  
  #r18 R
  srli r18, r19, 11
  andi r18, r18, 0x001F
  add  r18, r18, r20
  
  mov r4,r18
  mov r5, 64
  call checkbound 
  mov r18,r4
  
  #concaternate-> r19r19r19
  mov r2,r18
  slli r2, 6
  or r2,r17,r2
  slli r2, 5
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
 
 
checkbound:
  blt r4, 0, lessThanZero
  bgt r4,r5, higherThanBound
  
  lessThanZero:
  mov r4, 0 
  br retu
  
  higherThanBound:
  mov r4,r5
  br retu  
 
 retu:
 ret
  
 
  
  
  
  