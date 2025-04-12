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
  .space 4       # Storage for the total number of integers to insert
num_ints:
  .align 2
  .word 0        # Initially, there are 0 integers in the sorted array
array:
  .align 2
  .space 4096    # Storage for up to 1024 32-bit integers

################################################################################

.text

# print_array: prints n integers from the array
# Input:
#   $a0 = number of elements to print
#   $a1 = base address of the array
print_array:
  move $t0, $a0        # $t0 = number of elements to print
  li   $t1, 0          # index counter = 0
  move $t2, $a1        # $t2 = pointer to current array element
print_array_loop:
  beq  $t1, $t0, print_array_return  # if index equals n, finish
  li   $v0, 1          # syscall code to print integer
  lw   $a0, 0($t2)     # load current element from array
  syscall
  li   $v0, 4          # syscall code to print string
  la   $a0, space
  syscall
  addi $t1, $t1, 1     # increment index
  addi $t2, $t2, 4     # move pointer to next integer (4 bytes)
  j    print_array_loop
print_array_return:
  li   $v0, 4
  la   $a0, newline
  syscall
  jr   $ra

# sorted_array_insert:
# Inserts a new integer into a sorted array in ascending order.
#
# Input:
#   $a0 = new_int (the integer to insert)
#   $a1 = num_ints (current number of elements in the sorted array)
#   $a2 = base address of the array
#
# The function determines the correct insertion index, shifts elements (if necessary),
# and stores the new integer in its proper place.
sorted_array_insert:
  li   $t0, 0         # Initialize index counter: t0 = 0

  # Find the correct insertion index.
find_insertion:
  bge  $t0, $a1, insert_here   # if index >= current count, insert at end
  sll  $t1, $t0, 2    # t1 = t0 * 4 (offset for array index)
  add  $t2, $a2, $t1  # t2 = address of array[t0]
  lw   $t3, 0($t2)    # t3 = array[t0]
  blt  $a0, $t3, insert_here   # if new_int < array[t0], then stop: we found the insertion index
  addi $t0, $t0, 1    # Otherwise, increment index
  j    find_insertion

insert_here:
  # At this point, t0 holds the desired insertion index.
  # If t0 equals the current number of elements, no shifting is necessary.
  beq  $t0, $a1, store_element

  # Shift array elements to the right:
  # Start at the last element (index = num_ints - 1) and shift each one to the next index.
  addi $t4, $a1, -1   # t4 = last valid index = num_ints - 1
shift_loop:
  blt  $t4, $t0, store_element   # When t4 < insertion index, end shifting.
  sll  $t5, $t4, 2    # t5 = t4 * 4 (offset for element at index t4)
  add  $t6, $a2, $t5  # t6 = address of array[t4]
  lw   $t7, 0($t6)    # t7 = array[t4]
  addi $t5, $t5, 4    # t5 = offset for array[t4 + 1]
  add  $t8, $a2, $t5  # t8 = address of array[t4 + 1]
  sw   $t7, 0($t8)    # shift element from index t4 to index t4+1
  addi $t4, $t4, -1   # decrement shift index
  j    shift_loop

store_element:
  # Store new_int at the computed insertion index.
  sll  $t1, $t0, 2    # t1 = t0 * 4 (offset for insertion index)
  add  $t2, $a2, $t1  # t2 = address of array[t0]
  sw   $a0, 0($t2)    # store new_int into array at index t0
  jr   $ra

.globl main
main:
  # Save the return address in s0.
  move $s0, $ra

  # Prompt for the number of integers to insert.
  li   $v0, 4
  la   $a0, str1
  syscall
  li   $v0, 5
  syscall
  sw   $v0, n       # Store number of integers to insert in memory.
  move $s1, $v0     # s1 = total number to insert

gen_ints_0:
  beq  $s1, $zero, gen_ints_1

  # Prompt for a 32-bit integer to insert.
  li   $v0, 4
  la   $a0, str2
  syscall
  li   $v0, 5
  syscall
  move $s2, $v0     # s2 = new integer to insert

  # Call sorted_array_insert(new_int, current count in num_ints, base address of array)
  move $a0, $s2
  lw   $a1, num_ints
  la   $a2, array
  jal  sorted_array_insert

  # Increment the count of elements in the array.
  lw   $t0, num_ints
  addi $t0, $t0, 1
  sw   $t0, num_ints

  # Print the current state of the array.
  lw   $a0, num_ints
  la   $a1, array
  jal  print_array

  addi $s1, $s1, -1    # Decrement the total number to process
  j    gen_ints_0

gen_ints_1:
  # Restore $ra from s0 and return.
  move $ra, $s0
  jr   $ra
