################################################################################

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
  .space 1024  # <-- pre-allocate 1024 bytes for the first input string
inputStr2:
  .align 2
  .space 1024  # <-- pre-allocate 1024 bytes for the second input string

################################################################################

.text

# compareStrings
#
# $a0: the starting memory address of string0
# $a1: the starting memory address of string1
#
# $v0 =  1 (if string0 > string1)
#        0 (if string0 = string1)
#       -1 (if string0 < string1)
compareStrings:
################################################################################
# FIXME

  nop

# FIXME
################################################################################
  jr $ra

.globl main
main:

  # stack <-- $ra, $s0
  addi $sp, $sp, -8
  sw $ra, 0($sp)
  sw $s0, 4($sp)

  # print_string str1; read_string(inputStr1, $s0)
  li $v0, 4
  la $a0, str1
  syscall
  li $v0, 8
  la $a0, inputStr1
  li $a1, 1024
  syscall

  # print_string str2; read_string(inputStr2, $s1)
  li $v0, 4
  la $a0, str2
  syscall
  li $v0, 8
  la $a0, inputStr2
  li $a1, 1024
  syscall

  # compareStrings(inputStr1, inputStr2); $s2 = $v0
  la $a0, inputStr1
  la $a1, inputStr2
  jal compareStrings
  move $s2, $v0

  # print_string str3; print_string str4; print_int $s2; print_string newline
  li $v0, 4
  la $a0, str3
  syscall
  li $v0, 4
  la $a0, str4
  syscall
  li $v0, 1
  move $a0, $s2
  syscall
  li $v0, 4
  la $a0, newline
  syscall

  # $ra, $s0 <-- stack
  lw $ra, 0($sp)
  lw $s0, 4($sp)
  addi $sp, $sp, 8

  # return;
  jr $ra

################################################################################

