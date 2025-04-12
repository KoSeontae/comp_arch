.data
promptPush: .asciiz "Enter the number of integers to push into the min heap: "
promptVal:  .asciiz "Enter a 32-bit integer to push into the min heap (in decimal): "
msgPop:     .asciiz "INFO: Popping a 32-bit integer from the min heap:\n"
msgRet:     .asciiz "INFO: min_heap_pop returned:\n"
msgRes:     .asciiz "INFO:   $v0 = "
nl:         .asciiz "\n"
sp:         .asciiz " "
heap:       .space 4096

.text
print_heap:
    move  $t0, $a0
    li    $t1, 0
    move  $t2, $a1
hp_loop:
    beq   $t1, $t0, hp_done
    li    $v0, 1
    lw    $a0, 0($t2)
    syscall
    li    $v0, 4
    la    $a0, sp
    syscall
    addi  $t1, $t1, 1
    addi  $t2, $t2, 4
    j     hp_loop
hp_done:
    li    $v0, 4
    la    $a0, nl
    syscall
    jr    $ra

min_heap_push:
    move  $t0, $a0        # current count = index to insert
    sll   $t1, $t0, 2
    add   $t1, $a1, $t1
    sw    $a2, 0($t1)
mh_push_up:
    blez  $t0, mh_push_end
    addi  $t2, $t0, -1
    sra   $t2, $t2, 1     # parent index
    sll   $t3, $t2, 2
    add   $t3, $a1, $t3
    lw    $t4, 0($t3)
    sll   $t5, $t0, 2
    add   $t5, $a1, $t5
    lw    $t6, 0($t5)
    blt   $t6, $t4, mh_do_swap
    j     mh_push_end
mh_do_swap:
    sw    $t6, 0($t3)
    sw    $t4, 0($t5)
    move  $t0, $t2
    j     mh_push_up
mh_push_end:
    jr    $ra

min_heap_pop:
    lw    $v0, 0($a1)     # store root in v0
    addi  $t0, $a0, -1    # new heap count
    blez  $t0, mh_pop_end
    sll   $t1, $t0, 2
    add   $t1, $a1, $t1
    lw    $t2, 0($t1)
    sw    $t2, 0($a1)     # last element -> root
    li    $t3, 0         # current index = 0
mh_pop_down:
    sll   $t4, $t3, 1
    addi  $t4, $t4, 1     # left child index
    bge   $t4, $t0, mh_pop_end
    sll   $t5, $t4, 2
    add   $t5, $a1, $t5
    lw    $t6, 0($t5)     # left child value
    move  $t7, $t4       # candidate index = left child
    move  $t8, $t6       # candidate value = left child
    sll   $t9, $t3, 1
    addi  $t9, $t9, 2    # right child index
    blt   $t9, $t0, mh_check_right
    j     mh_compare
mh_check_right:
    sll   $t10, $t9, 2
    add   $t10, $a1, $t10
    lw    $t10, 0($t10)   # right child's value
    ble   $t10, $t8, mh_choose_right
    j     mh_compare
mh_choose_right:
    move  $t7, $t9
    move  $t8, $t10
mh_compare:
    sll   $t11, $t3, 2
    add   $t11, $a1, $t11
    lw    $t12, 0($t11)   # parent's value
    ble   $t12, $t8, mh_pop_end
    sw    $t8, 0($t11)
    sll   $t11, $t7, 2
    add   $t11, $a1, $t11
    sw    $t12, 0($t11)
    move  $t3, $t7
    j     mh_pop_down
mh_pop_end:
    jr    $ra

.globl main
main:
    li   $v0, 4
    la   $a0, promptPush
    syscall
    li   $v0, 5
    syscall
    move $s0, $v0      # total pushes
    li   $s1, 0        # current heap count
mh_push_loop:
    slt  $t0, $s1, $s0
    beq  $t0, $zero, mh_pop_phase
    li   $v0, 4
    la   $a0, promptVal
    syscall
    li   $v0, 5
    syscall
    move $s2, $v0
    move $a0, $s1
    la   $a1, heap
    move $a2, $s2
    jal  min_heap_push
    addi $s1, $s1, 1
    move $a0, $s1
    la   $a1, heap
    jal  print_heap
    j    mh_push_loop
mh_pop_phase:
    move $s3, $s1      # s3: current heap count
    li   $s1, 0       # popped count
mh_pop_loop:
    slt  $t0, $s1, $s0
    beq  $t0, $zero, mh_end
    li   $v0, 4
    la   $a0, msgPop
    syscall
    move $a0, $s3
    la   $a1, heap
    jal  min_heap_pop
    move $s4, $v0     # popped value
    li   $v0, 4
    la   $a0, msgRet
    syscall
    li   $v0, 4
    la   $a0, msgRes
    syscall
    li   $v0, 1
    move $a0, $s4
    syscall
    li   $v0, 4
    la   $a0, nl
    syscall
    addi $s1, $s1, 1
    addi $s3, $s3, -1
    move $a0, $s3
    la   $a1, heap
    jal  print_heap
    j    mh_pop_loop
mh_end:
    jr   $ra
