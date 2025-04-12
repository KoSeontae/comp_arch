################################################################################

.data

str1:
  .asciiz "Enter the number of integers to push into the min heap: "
str2:
  .asciiz "Enter a 32-bit integer to push into the min heap (in decimal): "
str3:
  .asciiz "INFO: Popping a 32-bit integer from the min heap:\n"
str4:
  .asciiz "INFO: min_heap_pop returned:\n"
str5:
  .asciiz "INFO:   $v0 = "
newline:
  .asciiz "\n"
space:
  .asciiz " "

min_heap:
  .align 2
  .space 4096

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

# $a0: the current number of elements in the binary min heap
# $a1: the starting memory address of the binary min heap
# $a2: the new 32-bit signed integer to push to the binary min heap
min_heap_push:
  move  $t0, $a0
  sll   $t1, $t0, 2
  add   $t1, $a1, $t1
  sw    $a2, 0($t1)
bubble_up:
  blez  $t0, push_end
  addi  $t2, $t0, -1
  sra   $t2, $t2, 1
  sll   $t3, $t2, 2
  add   $t3, $a1, $t3
  lw    $t4, 0($t3)
  sll   $t5, $t0, 2
  add   $t5, $a1, $t5
  lw    $t6, 0($t5)
  blt   $t6, $t4, do_swap
  j     push_end
do_swap:
  sw    $t6, 0($t3)
  sw    $t4, 0($t5)
  move  $t0, $t2
  j     bubble_up
push_end:
  jr $ra
  
.globl main
main:

  # stack << $ra
  addi $sp, $sp, -4
  sw $ra, 0($sp)

  # print_str(str1); $s0 = read_int()
  li $v0, 4
  la $a0, str1
  syscall
  li $v0, 5
  syscall
  move $s0, $v0

  # push $s0 integers into the binary min heap
  li $s1, 0
main_0:
  # print_str(str2)
  li $v0, 4
  la $a0, str2
  syscall
  # $s2 = read_int()
  li $v0, 5
  syscall
  move $s2, $v0
  # min_heap_push($s1, min_heap, $s2)
  move $a0, $s1
  la $a1, min_heap
  move $a2, $s2
  jal min_heap_push
  # $s1 = $s1 + 1
  addi $s1, $s1, 1
  # print_array($s1, min_heap)
  move $a0, $s1
  la $a1, min_heap
  jal print_array
  # if ($s1 < $s0) then goto main_0
  slt $t0, $s1, $s0
  bne $t0, $zero, main_0

main_1:

  # pop $s0 integers from the binary min heap
  move $s2, $s1
  li $s1, 0
main_2:
  # print_str(str3)
  li $v0, 4
  la $a0, str3
  syscall
  # min_heap_pop($s2, min_heap)
  move $a0, $s2
  la $a1, min_heap
  jal min_heap_pop
  # $s3 = $v0
  move $s3, $v0
  # print_str(str4)
  li $v0, 4
  la $a0, str4
  syscall
  # print_str(str5)
  li $v0, 4
  la $a0, str5
  syscall
  # print_int($s3)
  li $v0, 1
  move $a0, $s3
  syscall
  # print_str(newline)
  li $v0, 4
  la $a0, newline
  syscall
  
  # $s1 = $s1 + 1
  # $s2 = $s2 - 1
  addi $s1, $s1, 1
  addi $s2, $s2, -1

  # print_array($s2, min_heap)
  move $a0, $s2
  la $a1, min_heap
  jal print_array

  # if ($s1 < $s0) then goto main_2
  slt $t0, $s1, $s0
  bne $t0, $zero, main_2

main_3:

  # stack >> $ra
  lw $ra, 0($sp)
  addi $sp, $sp, 4

  jr $ra

