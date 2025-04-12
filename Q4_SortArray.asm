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
  .space 4        # Capable of storing a 32-bit unsigned integer

array:
  .align 2
  .space 4096     # Capable of storing up to 1024 32-bit integers

################################################################################

.text

# print_array: prints n integers from an array
# $a0 = n, $a1 = address of array[0]
print_array:
  move $t0, $a0       # $t0 holds the number of elements to print
  li   $t1, 0         # $t1 is the index counter
  move $t2, $a1       # $t2 points to the current array element
print_array_loop:
  beq  $t1, $t0, print_array_return  # If index equals n, finish printing
  li   $v0, 1         # syscall for print_int
  lw   $a0, 0($t2)    # load the current array element
  syscall
  li   $v0, 4         # syscall for print_string
  la   $a0, space
  syscall
  addi $t1, $t1, 1    # index++
  addi $t2, $t2, 4    # move pointer to the next integer (each int is 4 bytes)
  j    print_array_loop
print_array_return:
  li   $v0, 4
  la   $a0, newline
  syscall
  jr   $ra

# sort_array: sorts an array of 32-bit integers in ascending order using bubble sort.
# $a0 = n (number of elements), $a1 = base address of array.
sort_array:
  # Save number of elements in $t2
  move $t2, $a0        # $t2 = n

  li   $t0, 0          # Outer loop counter, i = 0
outer_loop:
  # Outer loop runs while i < n-1
  sub  $t3, $t2, 1     # $t3 = n - 1
  bge  $t0, $t3, sort_end  # if i >= n-1, we're done

  li   $t1, 0          # Inner loop counter, j = 0
inner_loop:
  # Inner loop runs for j < (n - i - 1)
  sub  $t4, $t2, $t0   # $t4 = n - i
  addi $t4, $t4, -1    # $t4 = n - i - 1
  bge  $t1, $t4, inner_end  # if j >= (n-i-1), exit inner loop

  # Compute address for array[j]: base + (j * 4)
  sll  $t6, $t1, 2     # $t6 = j * 4
  add  $t5, $a1, $t6   # $t5 = address of array[j]
  lw   $t7, 0($t5)     # $t7 = array[j]

  # Compute address for array[j+1]: base + ((j+1) * 4)
  addi $t8, $t1, 1     # $t8 = j + 1
  sll  $t8, $t8, 2     # $t8 = (j+1) * 4
  add  $t9, $a1, $t8   # $t9 = address of array[j+1]
  lw   $t8, 0($t9)     # $t8 = array[j+1]

  # Compare array[j] and array[j+1]; swap if out-of-order
  ble  $t7, $t8, no_swap  # if array[j] <= array[j+1], no swap needed

  # Swap:
  sw   $t8, 0($t5)     # store array[j+1] into array[j]
  sw   $t7, 0($t9)     # store array[j] into array[j+1]

no_swap:
  addi $t1, $t1, 1     # inner loop: j++
  j    inner_loop

inner_end:
  addi $t0, $t0, 1     # outer loop: i++
  j    outer_loop

sort_end:
  jr   $ra             # Return from sort_array

.globl main
main:
  # Save $ra in $s0
  move $s0, $ra

  # Prompt for number of integers to sort and read it
  li   $v0, 4
  la   $a0, str1
  syscall
  li   $v0, 5
  syscall
  sw   $v0, n         # Store n in memory

  # Read n integers, storing them in array
  move $t0, $v0      # $t0 = number of integers (n)
  la   $t1, array   # pointer to array base
gen_ints_0:
  beq  $t0, $zero, gen_ints_1

  # Prompt for each integer and read it
  li   $v0, 4
  la   $a0, str2
  syscall
  li   $v0, 5
  syscall
  sw   $v0, 0($t1)

  addi $t0, $t0, -1
  addi $t1, $t1, 4
  j    gen_ints_0
gen_ints_1:

  # Print original array
  lw   $a0, n
  la   $a1, array
  jal  print_array

  # Call sort_array(n, array)
  lw   $a0, n
  la   $a1, array
  jal  sort_array

  # Print sorted array
  lw   $a0, n
  la   $a1, array
  jal  print_array

  # Restore $ra from $s0 and return
  move $ra, $s0
  jr   $ra
