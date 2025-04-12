.data

newline:
  .asciiz "\n"

str0:
  .asciiz "Enter a 32-bit signed integer (in decimal): "

str1:
  .asciiz "INFO: fourWayAddAndSub returned:\n"
str2:
  .asciiz "INFO:   $v0 = "
str3:
  .asciiz "INFO:   $v1 = "

.text

# Function: fourWayAddAndSub
# Description:
#   - Computes the sum and difference of four 32-bit signed integers.
#   - Input:  $a0, $a1, $a2, $a3
#   - Output: $v0 = a0 + a1 + a2 + a3
#             $v1 = a0 - a1 - a2 - a3
fourWayAddAndSub:
  # Compute sum: v0 = a0 + a1 + a2 + a3
  add   $t0, $a0, $a1    # t0 = a0 + a1
  add   $t0, $t0, $a2    # t0 = a0 + a1 + a2
  add   $v0, $t0, $a3    # v0 = sum = a0 + a1 + a2 + a3

  # Compute difference: v1 = a0 - a1 - a2 - a3
  sub   $t1, $a0, $a1    # t1 = a0 - a1
  sub   $t1, $t1, $a2    # t1 = a0 - a1 - a2
  sub   $v1, $t1, $a3    # v1 = diff = a0 - a1 - a2 - a3

  jr    $ra             # Return to caller

.globl main
main:
  # Print prompt and read first integer -> $t0
  li   $v0, 4
  la   $a0, str0
  syscall
  li   $v0, 5
  syscall
  move $t0, $v0

  # Print prompt and read second integer -> $t1
  li   $v0, 4
  la   $a0, str0
  syscall
  li   $v0, 5
  syscall
  move $t1, $v0

  # Print prompt and read third integer -> $t2
  li   $v0, 4
  la   $a0, str0
  syscall
  li   $v0, 5
  syscall
  move $t2, $v0

  # Print prompt and read fourth integer -> $t3
  li   $v0, 4
  la   $a0, str0
  syscall
  li   $v0, 5
  syscall
  move $t3, $v0

  # Save registers (callee-saved) before calling the function
  move $s0, $ra
  move $s1, $a0
  move $s2, $a1
  move $s3, $a2
  move $s4, $a3

  # Set up arguments for fourWayAddAndSub:
  # Move the integers from temporary registers to argument registers
  move $a0, $t0
  move $a1, $t1
  move $a2, $t2
  move $a3, $t3

  jal fourWayAddAndSub  # Call the function

  # Restore registers after function call
  move $ra, $s0
  move $a0, $s1
  move $a1, $s2
  move $a2, $s3
  move $a3, $s4

  # Move the results from $v0 and $v1 to $t0 and $t1 for printing
  move $t0, $v0  # Sum
  move $t1, $v1  # Difference

  # Print the result messages
  li   $v0, 4
  la   $a0, str1
  syscall

  # Print the sum: message, integer, newline
  li   $v0, 4
  la   $a0, str2
  syscall
  li   $v0, 1
  move $a0, $t0
  syscall
  li   $v0, 4
  la   $a0, newline
  syscall

  # Print the difference: message, integer, newline
  li   $v0, 4
  la   $a0, str3
  syscall
  li   $v0, 1
  move $a0, $t1
  syscall
  li   $v0, 4
  la   $a0, newline
  syscall

  # Exit program
  li   $v0, 0
  jr   $ra
