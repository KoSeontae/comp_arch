.data

str1:
  .asciiz "Enter the number of integers to sort: "
str2:
  .asciiz "Enter a 32-bit integer (in decimal): "

newline:
  .asciiz "\n"
space:
  .asciiz " "

n:
  .align 2
  .space 4 # <-- capable of storing a 32-bit unsigned integer

array:
  .align 2
  .space 4096 # <-- capable of storing up to 1024 32-bit integers

################################################################################

.text

# $a0 = n, $a1 = &array[0]
print_array:
  move $t0, $a0
  li $t1, 0
  move $t2, $a1
print_array_loop:
  beq $t1, $t0, print_array_return
  li $v0, 1
  lw $a0, ($t2)
  syscall
  li $v0, 4
  la $a0, space
  syscall
  addi $t1, $t1, 1
  addi $t2, $t2, 4
  j print_array_loop
print_array_return:
  li $v0, 4
  la $a0, newline
  syscall
  jr $ra

# $a0 = n, $a1 = &array[0]
sort_array:
################################################################################
# FIXME

  nop

# FIXME
################################################################################
  jr $ra

.globl main
main:
  # $s0 = $ra
  move $s0, $ra

  # print_string(str1); read_int (--> $v0); *n = $v0
  li $v0, 4
  la $a0, str1
  syscall
  li $v0, 5
  syscall
  sw $v0, n

  # read_int for n times
  move $t0, $v0
  la $t1, array
gen_ints_0:
  beq $t0, $zero, gen_ints_1

  # print_string(str2); read_int (--> $v0); array <<= $v0
  li $v0, 4
  la $a0, str2
  syscall
  li $v0, 5
  syscall
  sw $v0, ($t1)

  addi $t0, $t0, -1
  addi $t1, $t1, 4

  beq $zero, $zero, gen_ints_0
gen_ints_1:

  # print_array(n, array)
  lw $a0, n
  la $a1, array
  jal print_array

  # sort_array(n, array)
  lw $a0, n
  la $a1, array
  jal sort_array
  
  # print_array(n, array)
  lw $a0, n
  la $a1, array
  jal print_array

  # $ra = $s0
  move $ra, $s0
 
  # return
  jr $ra

