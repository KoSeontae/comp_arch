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
  .space 4096        # Storage for up to 1024 integers

################################################################################

.text

# print_array:
#   Input: $a0 = number of elements, $a1 = base address of the array
print_array:
  move  $t0, $a0        # t0 = number of elements to print
  li    $t1, 0          # index = 0
  move  $t2, $a1        # t2 = pointer to current element
print_array_loop:
  beq   $t1, $t0, print_array_return
  li    $v0, 1          # syscall: print integer
  lw    $a0, 0($t2)
  syscall
  li    $v0, 4          # syscall: print string
  la    $a0, space
  syscall
  addi  $t1, $t1, 1
  addi  $t2, $t2, 4     # next integer (4 bytes)
  j     print_array_loop
print_array_return:
  li    $v0, 4
  la    $a0, newline
  syscall
  jr    $ra

# min_heap_push:
#   Inserts a new integer into the min heap.
#   Input:
#     $a0 = current heap count (n)
#     $a1 = base address of the heap
#     $a2 = new integer to push
min_heap_push:
  # Place new element at the end (index = n).
  move  $t0, $a0          # t0 = current index = n
  sll   $t1, $t0, 2       # t1 = n * 4 (byte offset)
  add   $t2, $a1, $t1     # t2 = address of heap[n]
  sw    $a2, 0($t2)       # store new integer at heap[n]

  # Bubble up: while the new element is not at the root and is less than its parent.
bubble_up:
  blez  $t0, push_end     # if index <= 0, we're done
  addi  $t3, $t0, -1      # t3 = t0 - 1
  sra   $t3, $t3, 1       # parent's index = (t0 - 1) / 2
  sll   $t4, $t3, 2       # t4 = parent's index * 4
  add   $t5, $a1, $t4     # t5 = address of parent
  lw    $t6, 0($t5)       # t6 = parent's value

  sll   $t7, $t0, 2       # t7 = current index * 4
  add   $t8, $a1, $t7     # t8 = address of current element
  lw    $t9, 0($t8)       # t9 = current element's value

  blt   $t9, $t6, do_swap # if new element < parent, swap
  j     push_end
do_swap:
  # Swap parent's and child's values.
  sw    $t9, 0($t5)       # parent's slot gets new element's value
  sw    $t6, 0($t8)       # child's slot gets parent's value
  move  $t0, $t3          # update index to parent's index
  j     bubble_up
push_end:
  jr    $ra

# min_heap_pop:
#   Removes the minimum (root) element from the heap.
#   Input:
#     $a0 = current heap count (n)
#     $a1 = base address of the heap
#   Output:
#     $v0 = popped (deleted) integer (minimum)
min_heap_pop:
  # Assume there is at least one element.
  lw    $v0, 0($a1)       # v0 = root element (to be returned)
  addi  $t0, $a0, -1      # t0 = new heap count = n - 1

  # If the heap now becomes empty, we are done.
  blez  $t0, pop_end

  # Move the last element into the root.
  sll   $t1, $t0, 2       # t1 = (n-1) * 4 (offset for last element)
  add   $t2, $a1, $t1     # t2 = address of last element
  lw    $t3, 0($t2)       # t3 = last element's value
  sw    $t3, 0($a1)       # move it to the root

  # Bubble down: start at index i = 0.
  li    $t4, 0           # t4 = current index (i)
bubble_down:
  # Compute left child index = 2*i + 1.
  sll   $t5, $t4, 1       # t5 = i * 2
  addi  $t5, $t5, 1       # t5 = left child index
  bge   $t5, $t0, pop_end # if left child index >= new count, done

  # Load left child's value.
  sll   $t6, $t5, 2       # t6 = left child index * 4
  add   $t7, $a1, $t6     # t7 = address of left child
  lw    $t8, 0($t7)       # t8 = left child's value

  # Compute right child index = 2*i + 2.
  sll   $t9, $t4, 1       # t9 = i * 2
  addi  $t9, $t9, 2       # t9 = right child index
  # Determine candidate child index for swap.
  blt   $t9, $t0, right_exists  # if right child exists, go check it
  move  $t10, $t5         # otherwise, candidate = left child
  j     compare_parent
right_exists:
  sll   $t11, $t9, 2      # t11 = right child offset = t9 * 4
  add   $t11, $a1, $t11   # t11 = address of right child
  lw    $t12, 0($t11)     # t12 = right child's value
  # Select candidate index:
  ble   $t12, $t8, choose_right  # if right child's value <= left child's, choose right
  move  $t10, $t5         # else choose left
  j     compare_parent
choose_right:
  move  $t10, $t9         # candidate = right child index

compare_parent:
  # Load parent's value from current index.
  sll   $t13, $t4, 2      # t13 = i * 4
  add   $t13, $a1, $t13   # t13 = address of parent
  lw    $t14, 0($t13)     # t14 = parent's value
  # Load candidate's value.
  sll   $t15, $t10, 2     # t15 = candidate index * 4
  add   $t15, $a1, $t15   # t15 = address of candidate
  lw    $t16, 0($t15)     # t16 = candidate's value
  # If parent's value <= candidate's value, the min-heap property is satisfied.
  ble   $t14, $t16, pop_end
  # Otherwise, swap parent with candidate.
  sw    $t16, 0($t13)     # parent's slot gets candidate's value
  sw    $t14, 0($t15)     # candidate's slot gets parent's value
  # Update index i to candidate index and continue.
  move  $t4, $t10
  j     bubble_down
pop_end:
  jr    $ra

.globl main
main:
  # Save $ra on stack.
  addi  $sp, $sp, -4
  sw    $ra, 0($sp)

  # Prompt for the number of integers to push into the min heap.
  li    $v0, 4
  la    $a0, str1
  syscall
  li    $v0, 5
  syscall
  move  $s0, $v0       # s0 = total number to push

  # Initialize heap count to 0.
  li    $s1, 0

  # Push integers into the min heap.
main_push:
  slt   $t0, $s1, $s0
  beq   $t0, $zero, pop_phase

  # Prompt for an integer.
  li    $v0, 4
  la    $a0, str2
  syscall
  li    $v0, 5
  syscall
  move  $s2, $v0       # s2 = new integer

  # Call min_heap_push(s1, min_heap, s2)
  move  $a0, $s1
  la    $a1, min_heap
  move  $a2, $s2
  jal   min_heap_push

  # Increment heap count.
  addi  $s1, $s1, 1

  # Print current state of the heap.
  move  $a0, $s1
  la    $a1, min_heap
  jal   print_array

  j     main_push

pop_phase:
  # Pop all integers from the heap.
  # s1 currently holds the number of elements in the heap.
  move  $s2, $s1       # s2 = current heap count
  li    $s1, 0        # s1 will count popped elements
pop_loop:
  slt   $t0, $s1, $s0
  beq   $t0, $zero, end_main

  # Print pop message.
  li    $v0, 4
  la    $a0, str3
  syscall

  # Call min_heap_pop with current heap count in s2.
  move  $a0, $s2
  la    $a1, min_heap
  jal   min_heap_pop
  move  $s3, $v0       # s3 holds the popped element

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

  # Update counters: one element popped.
  addi  $s1, $s1, 1    # popped count incremented
  addi  $s2, $s2, -1   # reduce heap count

  # Print updated heap.
  move  $a0, $s2
  la    $a1, min_heap
  jal   print_array

  j     pop_loop

end_main:
  lw    $ra, 0($sp)
  addi  $sp, $sp, 4
  jr    $ra
