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

# print_array:
#   Input: $a0 = number of elements, $a1 = base address of the array
print_array:
  move $t0, $a0          # $t0 = number of elements to print
  li   $t1, 0            # index counter = 0
  move $t2, $a1          # $t2 = pointer to current element
print_array_loop:
  beq  $t1, $t0, print_array_return
  li   $v0, 1            # syscall for print_int
  lw   $a0, 0($t2)
  syscall
  li   $v0, 4            # syscall for print_string
  la   $a0, space
  syscall
  addi $t1, $t1, 1
  addi $t2, $t2, 4       # each integer is 4 bytes
  j    print_array_loop
print_array_return:
  li   $v0, 4
  la   $a0, newline
  syscall
  jr   $ra

# min_heap_push:
#   Input: 
#     $a0 = current number of elements in the min heap
#     $a1 = base address of the min heap
#     $a2 = new 32-bit signed integer to push
#   Function:
#     - Place the new integer as the last element.
#     - Bubble it up until the min-heap property is restored.
min_heap_push:
  # Insert new element at the end.
  move  $t0, $a0           # t0 = index where new element is to be inserted
  sll   $t1, $t0, 2        # t1 = index * 4 (byte offset)
  add   $t2, $a1, $t1      # t2 = address of array[t0]
  sw    $a2, 0($t2)        # store new integer at end

  # Bubble up: while index > 0, compare with parent.
bubble_up_loop:
  blez  $t0, push_end      # if index <= 0, done
  addi  $t3, $t0, -1       # t3 = i - 1
  sra   $t3, $t3, 1        # t3 = (i - 1) / 2  (parent index)
  # Load current element.
  sll   $t4, $t0, 2        # t4 = i * 4
  add   $t5, $a1, $t4      # t5 = address of array[i]
  lw    $t6, 0($t5)        # t6 = element at index i
  # Load parent's element.
  sll   $t7, $t3, 2        # t7 = (parent index)*4
  add   $t8, $a1, $t7      # t8 = address of parent's element
  lw    $t9, 0($t8)        # t9 = parent's element

  # If new element is less than parent's element, swap.
  blt   $t6, $t9, do_swap
  j     push_end

do_swap:
  # Swap parent's and child's values.
  sw    $t9, 0($t5)        # child's slot gets parent's value
  sw    $t6, 0($t8)        # parent's slot gets child's value
  # Update index to parent's index.
  move  $t0, $t3
  j     bubble_up_loop

push_end:
  jr    $ra

# min_heap_pop:
#   Input:
#     $a0 = current number of elements in the min heap
#     $a1 = base address of the min heap
#   Output:
#     $v0 = the popped (deleted) 32-bit signed integer (the minimum)
#   Function:
#     - Remove the root element.
#     - Replace it with the last element.
#     - Bubble the element down to restore the min-heap property.
min_heap_pop:
  # Assume at least one element exists.
  lw    $v0, 0($a1)        # v0 = root element (to be returned)

  # Compute last index = current count - 1.
  addi  $t0, $a0, -1       # t0 = new number of elements after removal
  sll   $t1, $t0, 2        # t1 = (new count) * 4: offset of last element
  add   $t2, $a1, $t1      # t2 = address of last element
  lw    $t3, 0($t2)        # t3 = last element's value
  sw    $t3, 0($a1)        # Move last element to root

  # Bubble down: start at index i = 0.
  li    $t4, 0            # t4 = i, starting at root
bubble_down:
  # Compute left child index: left = 2*i + 1.
  move  $t5, $t4
  sll   $t5, $t5, 1       # t5 = i * 2
  addi  $t5, $t5, 1       # t5 = 2*i + 1 (left index)

  # If left child index >= new count, no children exist => done.
  bge   $t5, $t0, bubble_done

  # Load left child's value.
  sll   $t6, $t5, 2       # t6 = left index * 4
  add   $t7, $a1, $t6     # t7 = address of left child
  lw    $t8, 0($t7)       # t8 = left child's value

  # Compute right child index: right = 2*i + 2.
  move  $t9, $t4
  sll   $t9, $t9, 1       # t9 = i * 2
  addi  $t9, $t9, 2       # t9 = 2*i + 2 (right index)

  # Check if right child exists: if right index < new count.
  blt   $t9, $t0, check_right_child
  # Otherwise, candidate is left child.
  move  $t10, $t5         # candidate index = left index
  j     compare_parent

check_right_child:
  sll   $t11, $t9, 2      # t11 = right index * 4
  add   $t11, $a1, $t11   # t11 = address of right child
  lw    $t12, 0($t11)     # t12 = right child's value
  # Compare right and left child values.
  # If right child's value is less than or equal to left child's value, choose right.
  ble   $t12, $t8, choose_right
  # Otherwise, choose left.
  move  $t10, $t5         # candidate index = left index
  j     compare_parent

choose_right:
  move  $t10, $t9         # candidate index = right index

compare_parent:
  # Load parent's value.
  sll   $t13, $t4, 2      # t13 = i * 4
  add   $t13, $a1, $t13   # t13 = address of parent
  lw    $t14, 0($t13)     # t14 = parent's value
  # Load candidate's value.
  sll   $t15, $t10, 2     # t15 = candidate index * 4
  add   $t15, $a1, $t15   # t15 = address of candidate element
  lw    $t16, 0($t15)     # t16 = candidate's value
  # If parent's value <= candidate's value, the heap property is satisfied.
  ble   $t14, $t16, bubble_done

  # Otherwise, swap parent with candidate.
  sw    $t16, 0($t13)     # parent's slot gets candidate's value
  sw    $t14, 0($t15)     # candidate's slot gets parent's value

  # Update index i to candidate index and continue.
  move  $t4, $t10
  j     bubble_down

bubble_done:
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
  move  $s0, $v0  # s0 = total number of integers to push

  # Initialize s1 = 0, which will count the number of elements currently in the heap.
  li    $s1, 0

  # Push s0 integers into the min heap.
main_0:
  # Prompt for an integer.
  li    $v0, 4
  la    $a0, str2
  syscall
  li    $v0, 5
  syscall
  move  $s2, $v0  # s2 = new integer read

  # Call min_heap_push(s1, min_heap, s2)
  move  $a0, $s1
  la    $a1, min_heap
  move  $a2, $s2
  jal   min_heap_push

  # Increment the heap count (s1 = s1 + 1).
  addi  $s1, $s1, 1

  # Print the current state of the min heap.
  move  $a0, $s1
  la    $a1, min_heap
  jal   print_array

  # Continue until all integers are pushed.
  slt   $t0, $s1, $s0
  bne   $t0, $zero, main_0

  # Now, pop s0 integers from the min heap.
  move  $s2, $s1   # s2 = current number of elements in the heap
  li    $s1, 0     # s1 will count the number of popped elements

main_2:
  li    $v0, 4
  la    $a0, str3
  syscall
  # Call min_heap_pop(s2, min_heap)
  move  $a0, $s2
  la    $a1, min_heap
  jal   min_heap_pop
  move  $s3, $v0   # s3 = popped element

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

  # Update counters: one element popped; so s2 = s2 - 1 and s1 = s1 + 1.
  addi  $s1, $s1, 1
  addi  $s2, $s2, -1

  # Print current state of the heap.
  move  $a0, $s2
  la    $a1, min_heap
  jal   print_array

  slt   $t0, $s1, $s0
  bne   $t0, $zero, main_2

  # Restore $ra from stack.
  lw    $ra, 0($sp)
  addi  $sp, $sp, 4
  jr    $ra
