################################################################################

.data

str1:
  .asciiz "Enter the number of integers to insert into the array: "
str2:
  .asciiz "Enter a 32-bit integer to insert into the array (in decimal): "

newline:
  .asciiz "\n"
space:
  .asciiz " "

n:
  .align 2
  .space 4
num_ints:
  .align 2
  .word 0 # <-- initially, there are 0 integer in the array
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
  
# $a0 = new_int, $a1 = num_ints, $a2 = &array[0]
sorted_array_insert:
  li   $t0, 0
find_insertion:
  bge  $t0, $a1, insert_here
  sll  $t1, $t0, 2
  add  $t2, $a2, $t1
  lw   $t3, 0($t2)
  blt  $a0, $t3, insert_here
  addi $t0, $t0, 1
  j    find_insertion
insert_here:
  beq  $t0, $a1, store_element
  addi $t4, $a1, -1
shift_loop:
  blt  $t4, $t0, store_element
  sll  $t5, $t4, 2
  add  $t6, $a2, $t5
  lw   $t7, 0($t6)
  addi $t5, $t5, 4
  add  $t8, $a2, $t5
  sw   $t7, 0($t8)
  addi $t4, $t4, -1
  j    shift_loop
store_element:
  sll  $t1, $t0, 2
  add  $t2, $a2, $t1
  sw   $a0, 0($t2)
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

  move $s1, $v0

gen_ints_0:

  beq $s1, $zero, gen_ints_1

  # print_string(str2); read_int (--> $v0) --> $s2
  li $v0, 4
  la $a0, str2
  syscall
  li $v0, 5
  syscall
  move $s2, $v0

  # sorted_array_insert($s2, *num_ints, &array[0]); (*num_ints)++;
  move $a0, $s2
  lw $a1, num_ints
  la $a2, array
  jal sorted_array_insert
  lw $s2, num_ints
  addi $s2, $s2, 1
  sw $s2, num_ints

  # print_array(*num_ints, &array[0])
  lw $a0, num_ints
  la $a1, array
  jal print_array

  addi $s1, $s1, -1

  beq $zero, $zero, gen_ints_0

gen_ints_1:

  # $ra = $s0
  move $ra, $s0
 
  # return
  jr $ra

