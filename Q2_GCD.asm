.data
newline:
  .asciiz "\n"
str0:
  .asciiz "Enter a 32-bit unsigned integer (in decimal): "
str1:
  .asciiz "INFO: calculateGCD returned:\n"
str2:
  .asciiz "INFO:   $v0 = "
  
.text
# $a0: a 32-bit unsigned integer
# $a1: a 32-bit unsigned integer
# $v0: the greatest common divisor of $a0 and $a1
calculateGCD:
  beq   $a1, $zero, gcd_end
gcd_loop:
  div   $a0, $a1
  mfhi  $t0
  move  $a0, $a1
  move  $a1, $t0
  bne   $a1, $zero, gcd_loop
gcd_end:
  move  $v0, $a0
  jr    $ra
  
.globl main
main:
  li   $v0, 4
  la   $a0, str0
  syscall
  
  li   $v0, 5
  syscall
  move $t0, $v0
  
  li   $v0, 4
  la   $a0, str0
  syscall
  
  li   $v0, 5
  syscall
  move $t1, $v0
  
  move $s0, $ra
  move $s1, $a0
  move $s2, $a1
  
  move $a0, $t0
  move $a1, $t1
  jal calculateGCD
  
  move $ra, $s0
  move $a0, $s1
  move $a1, $s2
  
  move $t0, $v0
  li   $v0, 4
  la   $a0, str1
  syscall
  
  li   $v0, 4
  la   $a0, str2
  syscall
  li   $v0, 1
  move $a0, $t0
  syscall
  
  li   $v0, 4
  la   $a0, newline
  syscall
  
  li   $v0, 0
  jr   $ra
