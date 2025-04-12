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
  .space 4 # <-- capable of storing a 32-bit unsigned integer

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

# $a0 = n, $a1 = &array[0]
sort_array:
    move  $t0, $a0         # $t0 = n
    li    $t1, 0           # outer loop index i = 0
outer_loop:
    sub   $t2, $a0, $t1    # t2 = n - i
    addi  $t2, $t2, -1     # t2 = n - i - 1 (내부 반복 횟수)
    blez  $t2, sort_end    # if (n-i-1) <= 0, 정렬 종료
    li    $t3, 0           # inner loop index j = 0
inner_loop:
    bge   $t3, $t2, outer_next   # if (j >= n-i-1) → inner loop 종료
    sll   $t4, $t3, 2      # t4 = j * 4 (바이트 오프셋)
    add   $t5, $a1, $t4    # t5 = 주소 of array[j]
    lw    $t6, 0($t5)      # t6 = array[j]
    addi  $t4, $t4, 4      # t4 = (j+1) * 4
    add   $t7, $a1, $t4    # t7 = 주소 of array[j+1]
    lw    $t8, 0($t7)      # t8 = array[j+1]
    ble   $t6, $t8, inner_next  # if (array[j] <= array[j+1]) → no swap
    sw    $t8, 0($t5)      # swap: array[j] <- array[j+1]
    sw    $t6, 0($t7)      # swap: array[j+1] <- array[j]
inner_next:
    addi  $t3, $t3, 1      # j++
    j     inner_loop
outer_next:
    addi  $t1, $t1, 1      # i++
    j     outer_loop
sort_end:
    jr  $ra


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

  # read_int for n times
  move $t0, $v0
  la $t1, array
gen_ints_0:
  beq $t0, $zero, gen_ints_1

  # print_string(str2); read_int (--> $v0); array <<= $v0
  li $v0, 4
  la $a0, str2
  syscall
  li $v0, 5
  syscall
  sw $v0, ($t1)

  addi $t0, $t0, -1
  addi $t1, $t1, 4

  beq $zero, $zero, gen_ints_0
gen_ints_1:

  # print_array(n, array)
  lw $a0, n
  la $a1, array
  jal print_array

  # sort_array(n, array)
  lw $a0, n
  la $a1, array
  jal sort_array
  
  # print_array(n, array)
  lw $a0, n
  la $a1, array
  jal print_array

  # $ra = $s0
  move $ra, $s0
 
  # return
  jr $ra