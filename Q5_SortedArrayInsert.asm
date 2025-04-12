.data
promptCount: .asciiz "Enter the number of integers to insert into the array: "
promptNum:   .asciiz "Enter a 32-bit integer to insert into the array (in decimal): "
nl:          .asciiz "\n"
sp:          .asciiz " "
n:           .space 4
curCount:    .word 0
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

sorted_array_insert:
    li   $t0, 0
find_pos:
    bge  $t0, $a1, ins_here
    sll  $t1, $t0, 2
    add  $t1, $a2, $t1
    lw   $t2, 0($t1)
    blt  $a0, $t2, ins_here
    addi $t0, $t0, 1
    j    find_pos
ins_here:
    beq  $t0, $a1, do_store
    addi $t3, $a1, -1
shift_loop:
    blt  $t3, $t0, do_store
    sll  $t4, $t3, 2
    add  $t4, $a2, $t4
    lw   $t5, 0($t4)
    addi $t4, $t4, 4
    add  $t6, $a2, $t4
    sw   $t5, 0($t6)
    addi $t3, $t3, -1
    j    shift_loop
do_store:
    sll  $t1, $t0, 2
    add  $t1, $a2, $t1
    sw   $a0, 0($t1)
    jr   $ra

.globl main
main:
    li    $v0, 4
    la    $a0, promptCount
    syscall
    li    $v0, 5
    syscall
    sw    $v0, n
    move  $s1, $v0
gen_loop:
    beq   $s1, $zero, end_gen
    li    $v0, 4
    la    $a0, promptNum
    syscall
    li    $v0, 5
    syscall
    move  $s2, $v0
    move  $a0, $s2
    lw    $a1, curCount
    la    $a2, array
    jal   sorted_array_insert
    lw    $t0, curCount
    addi  $t0, $t0, 1
    sw    $t0, curCount
    lw    $a0, curCount
    la    $a1, array
    jal   print_array
    addi  $s1, $s1, -1
    j     gen_loop
end_gen:
    jr    $ra
