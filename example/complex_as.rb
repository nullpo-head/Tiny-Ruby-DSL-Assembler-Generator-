label :zero
  addi r1, r0, 1
  addi r2, r0, 2
  addi r3, r0, 3
  addi r4, r0, 20
  addi r5, r0, 21
  addi r6, r0, 18
  add r1, r1, r2
  beq r1, r3, :L1
  j :zero
label :L1
  sub r1, r1, r2                    
  lw r1, 0, r5
  lw r2, 0, r4
  sw r1, 0, r4
  sw r2, 4, r5
  lw r2, 0, r4
  lw r1, 4, r5
  jr r6
  j :zero
  write r1
label :loop
  j :loop
  val 65
  val 127
