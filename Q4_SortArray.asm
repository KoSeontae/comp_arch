.data
promptCount: .asciiz "Enter the number of integers to sort: "
promptInt:   .asciiz "Enter a 32-bit integer (in decimal): "
nl:          .asciiz "\n"
sp:          .asciiz " "
n:           .space 4
array:       .space 4096

.text
print_array:
    move  $t0, $a0
    li    $t1, 0
    move  $t2, $a1
pa_loop:
    beq   $t1, $t0, pa_done
    li    $v0, 1
    lw    $a0, 0($t2)
    syscall
    li    $v0, 4
    la    $a0, sp
    syscall
    addi  $t1, $t1, 1
    addi  $t2, $t2, 4
    j     pa_loop
pa_done:
    li    $v0, 4
    la    $a0, nl
    syscall
    jr    $ra

sort_array:
    move  $s0, $a0       # s0 = n (정수 개수)
    li    $t0, 0         # i = 0
outer_loop:
    sub   $t1, $s0, 1
    bge   $t0, $t1, sort_done
    li    $t2, 0         # j = 0
inner_loop:
    sub   $t3, $s0, $t0
    addi  $t3, $t3, -1
    bge   $t2, $t3, next_outer
    sll   $t4, $t2, 2
    add   $t4, $a1, $t4   # 주소: array[j]
    lw    $t5, 0($t4)     # array[j]
    addi  $t6, $t2, 1
    sll   $t6, $t6, 2
    add   $t6, $a1, $t6   # 주소: array[j+1]
    lw    $t7, 0($t6)     # array[j+1]
    ble   $t5, $t7, no_swap
    sw    $t7, 0($t4)
    sw    $t5, 0($t6)
no_swap:
    addi  $t2, $t2, 1
    j     inner_loop
next_outer:
    addi  $t0, $t0, 1
    j     outer_loop
sort_done:
    jr    $ra

.globl main
main:
    li    $v0, 4
    la    $a0, promptCount
    syscall
    li    $v0, 5
    syscall
    sw    $v0, n       # 저장된 n
    move  $t0, $v0     # 남은 개수
    la    $t1, array
read_loop:
    beq   $t0, $zero, sort_phase
    li    $v0, 4
    la    $a0, promptInt
    syscall
    li    $v0, 5
    syscall
    sw    $v0, 0($t1)
    addi  $t0, $t0, -1
    addi  $t1, $t1, 4
    j     read_loop
sort_phase:
    lw    $a0, n
    la    $a1, array
    jal   print_array
    lw    $a0, n
    la    $a1, array
    jal   sort_array
    lw    $a0, n
    la    $a1, array
    jal   print_array
    jr    $ra
