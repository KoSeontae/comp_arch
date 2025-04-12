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
  .space 4
array:
  .align 2
  .space 4096
  
.text
# $a0 = n, $a1 = &array[0]
print_array:
  move $t0, $a0
  li   $t1, 0
  move $t2, $a1
print_array_loop:
  beq $t1, $t0, print_array_return
  li  $v0, 1
  lw  $a0, ($t2)
  syscall
  li  $v0, 4
  la  $a0, space
  syscall
  addi $t1, $t1, 1
  addi $t2, $t2, 4
  j   print_array_loop
print_array_return:
  li  $v0, 4
  la  $a0, newline
  syscall
  jr  $ra
  
# $a0 = n, $a1 = &array[0]
sort_array:
  move $t2, $a0
  li   $t0, 0
outer_loop:
  sub  $t3, $t2, 1
  bge  $t0, $t3, sort_end
  li   $t1, 0
inner_loop:
  sub  $t4, $t2, $t0
  addi $t4, $t4, -1
  bge  $t1, $t4, inner_end
  sll  $t5, $t1, 2
  add  $t5, $a1, $t5
  lw   $t6, 0($t5)
  addi $t7, $t1, 1
  sll  $t7, $t7, 2
  add  $t7, $a1, $t7
  lw   $t8, 0($t7)
  ble  $t6, $t8, no_swap
  sw   $t8, 0($t5)
  sw   $t6, 0($t7)
no_swap:
  addi $t1, $t1, 1
  j inner_loop
inner_end:
  addi $t0, $t0, 1
  j outer_loop
sort_end:
  jr  $ra
  
.globl main
main:
  li   $v0, 4
  la   $a0, str1
  syscall
  li   $v0, 5
  syscall
  sw   $v0, n
  move $t0, $v0
  la   $t1, array
gen_ints_0:
  beq  $t0, $zero, gen_ints_1
  li   $v0, 4
  la   $a0, str2
  syscall
  li   $v0, 5
  syscall
  sw   $v0, ($t1)
  addi $t0, $t0, -1
  addi $t1, $t1, 4
  j gen_ints_0
gen_ints_1:
  lw   $a0, n
  la   $a1, array
  jal  print_array
  lw   $a0, n
  la   $a1, array
  jal  sort_array
  lw   $a0, n
  la   $a1, array
  jal  print_array
  jr  $ra
