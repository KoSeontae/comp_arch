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
  
.text
# $a0 = n, $a1 = &min_heap
print_array:
  move  $t0, $a0
  li    $t1, 0
  move  $t2, $a1
print_array_loop:
  beq   $t1, $t0, print_array_return
  li    $v0, 1
  lw    $a0, 0($t2)
  syscall
  li    $v0, 4
  la    $a0, space
  syscall
  addi  $t1, $t1, 1
  addi  $t2, $t2, 4
  j     print_array_loop
print_array_return:
  li    $v0, 4
  la    $a0, newline
  syscall
  jr    $ra
  
# $a0: current heap count, $a1: base address of min_heap, $a2: new integer
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
  jr    $ra
  
# $a0: current heap count, $a1: base address of min_heap
min_heap_pop:
  lw    $v0, 0($a1)
  addi  $t0, $a0, -1
  blez  $t0, pop_end
  sll   $t1, $t0, 2
  add   $t1, $a1, $t1
  lw    $t2, 0($t1)
  sw    $t2, 0($a1)
  li    $t4, 0
bubble_down:
  sll   $t1, $t4, 1
  addi  $t1, $t1, 1
  bge   $t1, $t0, pop_end
  sll   $t2, $t1, 2
  add   $t2, $a1, $t2
  lw    $t5, 0($t2)
  sll   $t6, $t4, 1
  addi  $t6, $t6, 2
  move  $t7, $t1
  move  $t8, $t5
  blt   $t6, $t0, check_right
  j     compare_parent
check_right:
  sll   $t9, $t6, 2
  add   $t9, $a1, $t9
  lw    $t9, 0($t9)
  ble   $t9, $t8, choose_right
  j     compare_parent
choose_right:
  move  $t7, $t6
  move  $t8, $t9
compare_parent:
  sll   $t1, $t4, 2
  add   $t1, $a1, $t1
  lw    $t3, 0($t1)
  ble   $t3, $t8, pop_end
  sw    $t8, 0($t1)
  sll   $t1, $t7, 2
  add   $t1, $a1, $t1
  sw    $t3, 0($t1)
  move  $t4, $t7
  j     bubble_down
pop_end:
  jr    $ra
  
.globl main
main:
  addi  $sp, $sp, -4
  sw    $ra, 0($sp)
  
  li    $v0, 4
  la    $a0, str1
  syscall
  li    $v0, 5
  syscall
  move  $s0, $v0
  
  li    $s1, 0
main_push:
  slt   $t0, $s1, $s0
  beq   $t0, $zero, pop_phase
  
  li    $v0, 4
  la    $a0, str2
  syscall
  li    $v0, 5
  syscall
  move  $s2, $v0
  
  move  $a0, $s1
  la    $a1, min_heap
  move  $a2, $s2
  jal   min_heap_push
  
  addi  $s1, $s1, 1
  
  move  $a0, $s1
  la    $a1, min_heap
  jal   print_array
  
  j     main_push
  
pop_phase:
  move  $s2, $s1
  li    $s1, 0
pop_loop:
  slt   $t0, $s1, $s0
  beq   $t0, $zero, main_end
  
  li    $v0, 4
  la    $a0, str3
  syscall
  
  move  $a0, $s2
  la    $a1, min_heap
  jal   min_heap_pop
  move  $s3, $v0
  
  li    $v0, 4
  la    $a0, str4
  syscall
  li    $v0, 4
  la    $a0, str5
  syscall
  li    $v0, 1
  move  $a0, $s3
  syscall
  li    $v0, 4
  la    $a0, newline
  syscall
  
  addi  $s1, $s1, 1
  addi  $s2, $s2, -1
  
  move  $a0, $s2
  la    $a1, min_heap
  jal   print_array
  
  j     pop_loop
main_end:
  lw    $ra, 0($sp)
  addi  $sp, $sp, 4
  jr    $ra
