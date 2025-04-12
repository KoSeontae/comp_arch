.data
newline:
  .asciiz "\n"
str1:
  .asciiz "Enter the first string: "
str2:
  .asciiz "Enter the second string: "
str3:
  .asciiz "INFO: compareStrings returned:\n"
str4:
  .asciiz "INFO:   $v0 = "
inputStr1:
  .align 2
  .space 1024
inputStr2:
  .align 2
  .space 1024
  
.text
# $a0: the starting memory address of string0
# $a1: the starting memory address of string1
# $v0 =  1 (if string0 > string1)
#        0 (if string0 = string1)
#       -1 (if string0 < string1)
compareStrings:
  move $t5, $a0
  move $t6, $a1
  move $t0, $a0
  li   $t1, 0
strlen_a:
  lb   $t2, 0($t0)
  beq  $t2, $zero, strlen_a_done
  addi $t1, $t1, 1
  addi $t0, $t0, 1
  j    strlen_a
strlen_a_done:
  move $t3, $a1
  li   $t4, 0
strlen_b:
  lb   $t2, 0($t3)
  beq  $t2, $zero, strlen_b_done
  addi $t4, $t4, 1
  addi $t3, $t3, 1
  j    strlen_b
strlen_b_done:
  bgt  $t1, $t4, ret_one
  blt  $t1, $t4, ret_neg
lex_cmp:
  lb   $t2, 0($t5)
  lb   $t3, 0($t6)
  beq  $t2, $zero, ret_zero
  bgt  $t2, $t3, ret_one
  blt  $t2, $t3, ret_neg
  addi $t5, $t5, 1
  addi $t6, $t6, 1
  j    lex_cmp
ret_zero:
  li   $v0, 0
  j    cmp_end
ret_one:
  li   $v0, 1
  j    cmp_end
ret_neg:
  li   $v0, -1
cmp_end:
  jr   $ra
  
.globl main
main:
  addi $sp, $sp, -8
  sw   $ra, 0($sp)
  sw   $s0, 4($sp)
  
  li   $v0, 4
  la   $a0, str1
  syscall
  
  li   $v0, 8
  la   $a0, inputStr1
  li   $a1, 1024
  syscall
  
  li   $v0, 4
  la   $a0, str2
  syscall
  
  li   $v0, 8
  la   $a0, inputStr2
  li   $a1, 1024
  syscall
  
  la   $a0, inputStr1
  la   $a1, inputStr2
  jal  compareStrings
  move $s2, $v0
  
  li   $v0, 4
  la   $a0, str3
  syscall
  
  li   $v0, 4
  la   $a0, str4
  syscall
  
  li   $v0, 1
  move $a0, $s2
  syscall
  
  li   $v0, 4
  la   $a0, newline
  syscall
  
  lw   $ra, 0($sp)
  lw   $s0, 4($sp)
  addi $sp, $sp, 8
  jr   $ra
