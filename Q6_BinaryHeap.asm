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
  .space 4096        # storage for up to 1024 integers

################################################################################

.text

# print_array:
#   Input: $a0 = number of elements, $a1 = base address of the array
print_array:
  move  $t0, $a0         # t0 = number of elements to print
  li    $t1, 0           # index = 0
  move  $t2, $a1         # t2 = pointer to current element
print_array_loop:
  beq   $t1, $t0, print_array_return
  li    $v0, 1           # syscall to print integer
  lw    $a0, 0($t2)
  syscall
  li    $v0, 4           # syscall to print string (space)
  la    $a0, space
  syscall
  addi  $t1, $t1, 1
  addi  $t2, $t2, 4      # next element (4 bytes)
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
  # Insert new element at the end (index = n).
  move  $t0, $a0         # t0 = current index
  sll   $t1, $t0, 2      # t1 = index * 4
  add   $t1, $a1, $t1    # t1 = address of heap[n]
  sw    $a2, 0($t1)      # store new integer at heap[n]

  # Bubble up: compare the element with its parent.
bubble_up:
  blez  $t0, push_end    # if index <= 0, stop bubbling up
  addi  $t2, $t0, -1     # t2 = t0 - 1
  sra   $t2, $t2, 1      # t2 = parent index = (t0-1)/2
  sll   $t3, $t2, 2      # t3 = parent index * 4
  add   $t3, $a1, $t3    # t3 = address of parent
  lw    $t4, 0($t3)      # t4 = parent's value
  sll   $t5, $t0, 2      # t5 = current index * 4
  add   $t5, $a1, $t5    # t5 = address of current element
  lw    $t6, 0($t5)      # t6 = current element's value
  blt   $t6, $t4, do_swap   # if current < parent, swap
  j     push_end
do_swap:
  sw    $t6, 0($t3)      # parent's slot gets current value
  sw    $t4, 0($t5)      # current slot gets parent's value
  move  $t0, $t2         # update current index to parent's index
  j     bubble_up
push_end:
  jr    $ra

# min_heap_pop:
#   Removes and returns the minimum (root) element from the min heap.
#   Input:
#     $a0 = current heap count (n)
#     $a1 = base address of the heap
#   Output:
#     $v0 = popped integer (minimum)
min_heap_pop:
  # Save the root element to return.
  lw    $v0, 0($a1)       # v0 = root element
  addi  $t0, $a0, -1      # t0 = new heap count = n - 1
  blez  $t0, pop_end      # if the heap becomes empty, finish pop

  # Move the last element into the root.
  sll   $t1, $t0, 2       # t1 = (n-1)*4
  add   $t1, $a1, $t1     # t1 = address of last element
  lw    $t2, 0($t1)       # t2 = last element's value
  sw    $t2, 0($a1)       # store it at the root

  # Bubble down: restore the min-heap property.
  li    $t4, 0           # t4 = current index (i = 0)
bubble_down:
  # Compute left child index = 2*i + 1.
  sll   $t1, $t4, 1       # t1 = i * 2
  addi  $t1, $t1, 1       # t1 = left child index
  bge   $t1, $t0, pop_end  # if left child index >= new count, done

  # Load left child's value.
  move  $t2, $t1          # t2 = left child index
  sll   $t3, $t2, 2       # t3 = left child index * 4
  add   $t3, $a1, $t3     # t3 = address of left child
  lw    $t5, 0($t3)       # t5 = left child's value
  
  # Compute right child index = 2*i + 2.
  sll   $t6, $t4, 1       # t6 = i * 2
  addi  $t6, $t6, 2       # t6 = right child index
  # Default candidate index is left child.
  move  $t7, $t1          # t7 = candidate index (initially left child)
  move  $t8, $t5          # t8 = candidate value (initially left child's value)
  
  # Check if right child exists.
  blt   $t6, $t0, right_exists_label
  j     compare_parent
right_exists_label:
  # Load right child's value.
  sll   $t9, $t6, 2       # t9 = right child index * 4
  add   $t9, $a1, $t9     # t9 = address of right child
  lw    $t9, 0($t9)       # t9 = right child's value
  # If right child's value is less than or equal to candidate's, choose right child.
  ble   $t9, $t8, choose_right_label
  j     compare_parent
choose_right_label:
  move  $t7, $t6          # candidate index = right child index
  move  $t8, $t9          # candidate value = right child's value
compare_parent:
  # Load parent's value.
  sll   $t1, $t4, 2       # t1 = i * 4
  add   $t1, $a1, $t1     # t1 = address of parent
  lw    $t3, 0($t1)       # t3 = parent's value
  # If parent's value is less than or equal to candidate's value, the heap property holds.
  ble   $t3, $t8, pop_end
  # Otherwise, swap parent with candidate.
  sw    $t8, 0($t1)       # store candidate value in parent's slot
  sll   $t1, $t7, 2       # t1 = candidate index * 4
  add   $t1, $a1, $t1     # t1 = address of candidate
  sw    $t3, 0($t1)       # store parent's value in candidate's slot
  move  $t4, $t7          # update current index to candidate index
  j     bubble_down
pop_end:
  jr    $ra

.globl main
main:
  # Save return address.
  addi  $sp, $sp, -4
  sw    $ra, 0($sp)

  # Prompt for the number of integers to push into the min heap.
  li    $v0, 4
  la    $a0, str1
  syscall
  li    $v0, 5
  syscall
  move  $s0, $v0         # s0 = total number to push

  # Initialize heap count in s1 to 0.
  li    $s1, 0

main_push:
  slt   $t0, $s1, $s0
  beq   $t0, $zero, pop_phase

  # Prompt for an integer.
  li    $v0, 4
  la    $a0, str2
  syscall
  li    $v0, 5
  syscall
  move  $s2, $v0         # s2 = new integer

  # Call min_heap_push with (current count, min_heap, new integer).
  move  $a0, $s1
  la    $a1, min_heap
  move  $a2, $s2
  jal   min_heap_push

  # Increment heap count.
  addi  $s1, $s1, 1

  # Print current heap.
  move  $a0, $s1
  la    $a1, min_heap
  jal   print_array

  j     main_push

pop_phase:
  # Set s2 = current heap count.
  move  $s2, $s1
  li    $s1, 0          # s1 will count popped elements

pop_loop:
  slt   $t0, $s1, $s0
  beq   $t0, $zero, end_main

  li    $v0, 4
  la    $a0, str3
  syscall

  # Call min_heap_pop with (current heap count in s2, min_heap).
  move  $a0, $s2
  la    $a1, min_heap
  jal   min_heap_pop
  move  $s3, $v0         # s3 = popped element

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
  addi  $s1, $s1, 1      # increment popped count
  addi  $s2, $s2, -1     # decrement current heap count

  # Print updated heap.
  move  $a0, $s2
  la    $a1, min_heap
  jal   print_array

  j     pop_loop

end_main:
  lw    $ra, 0($sp)
  addi  $sp, $sp, 4
  jr    $ra
