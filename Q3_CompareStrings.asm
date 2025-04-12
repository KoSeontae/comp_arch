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

.text

# compareStrings
#
# $a0: the starting memory address of string0 (first string)
# $a1: the starting memory address of string1 (second string)
#
# $v0 =  1 (if string0 > string1)
#        0 (if string0 = string1)
#       -1 (if string0 < string1)
compareStrings:
  # Save original pointers for lexicographical comparison.
  move $t5, $a0      # $t5 will point to the first string
  move $t6, $a1      # $t6 will point to the second string

  # Compute the length of the first string.
  move $t0, $a0      # pointer for computing length of string0
  li   $t1, 0        # initialize length counter for string0 to 0
strlen_a:
  lb   $t2, 0($t0)   # load byte from string0
  beq  $t2, $zero, strlen_a_done  # if null terminator, finish
  addi $t1, $t1, 1   # increment length counter
  addi $t0, $t0, 1   # move pointer to next character
  j    strlen_a
strlen_a_done:

  # Compute the length of the second string.
  move $t3, $a1      # pointer for computing length of string1
  li   $t4, 0        # initialize length counter for string1 to 0
strlen_b:
  lb   $t2, 0($t3)   # load byte from string1
  beq  $t2, $zero, strlen_b_done  # if null terminator, finish
  addi $t4, $t4, 1   # increment length counter
  addi $t3, $t3, 1   # move pointer to next character
  j    strlen_b
strlen_b_done:

  # Compare lengths: if they differ, decide based on length.
  bgt  $t1, $t4, return_one  # if length(string0) > length(string1), return 1
  blt  $t1, $t4, return_neg  # if length(string0) < length(string1), return -1

  # If lengths are equal, perform lexicographical comparison.
lex_cmp:
  lb   $t2, 0($t5)   # load a byte from string0
  lb   $t3, 0($t6)   # load a byte from string1
  beq  $t2, $zero, lex_done  # if reached the end of the string, they are equal
  bgt  $t2, $t3, return_one  # if character in string0 > corresponding in string1, return 1
  blt  $t2, $t3, return_neg  # if character in string0 < corresponding in string1, return -1
  addi $t5, $t5, 1   # move to next character in string0
  addi $t6, $t6, 1   # move to next character in string1
  j    lex_cmp
lex_done:
  li   $v0, 0       # strings are equal
  j    compareStrings_end

return_one:
  li   $v0, 1
  j    compareStrings_end
return_neg:
  li   $v0, -1

compareStrings_end:
  jr   $ra

.globl main
main:

  # stack <-- $ra, $s0
  addi $sp, $sp, -8
  sw   $ra, 0($sp)
  sw   $s0, 4($sp)

  # print_string str1; read_string(inputStr1, 1024)
  li   $v0, 4
  la   $a0, str1
  syscall
  li   $v0, 8
  la   $a0, inputStr1
  li   $a1, 1024
  syscall

  # print_string str2; read_string(inputStr2, 1024)
  li   $v0, 4
  la   $a0, str2
  syscall
  li   $v0, 8
  la   $a0, inputStr2
  li   $a1, 1024
  syscall

  # call compareStrings(inputStr1, inputStr2); result in $v0, save it in $s2.
  la   $a0, inputStr1
  la   $a1, inputStr2
  jal  compareStrings
  move $s2, $v0

  # print_string str3; print_string str4; print_int $s2; print_string newline
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

  # restore stack: $ra, $s0
  lw   $ra, 0($sp)
  lw   $s0, 4($sp)
  addi $sp, $sp, 8

  # return;
  jr   $ra
