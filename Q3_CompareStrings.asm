.data
nl:       .asciiz "\n"
prompt1:  .asciiz "Enter the first string: "
prompt2:  .asciiz "Enter the second string: "
msgComp:  .asciiz "INFO: compareStrings returned:\n"
msgRes:   .asciiz "INFO:   $v0 = "
buf1:     .align 2
          .space 1024
buf2:     .align 2
          .space 1024

.text
compareStrings:
    move  $s0, $a0       # s0 = ptr to string1
    move  $s1, $a1       # s1 = ptr to string2
    # 길이 계산
    move  $t0, $s0
    li    $t1, 0
len1:
    lb    $t2, 0($t0)
    beq   $t2, $zero, done_len1
    addi  $t1, $t1, 1
    addi  $t0, $t0, 1
    j     len1
done_len1:
    move  $t3, $s1
    li    $t4, 0
len2:
    lb    $t2, 0($t3)
    beq   $t2, $zero, done_len2
    addi  $t4, $t4, 1
    addi  $t3, $t3, 1
    j     len2
done_len2:
    bgt   $t1, $t4, retPos
    blt   $t1, $t4, retNeg
compLoop:
    lb    $t5, 0($s0)
    lb    $t6, 0($s1)
    beq   $t5, $zero, retZero
    bgt   $t5, $t6, retPos
    blt   $t5, $t6, retNeg
    addi  $s0, $s0, 1
    addi  $s1, $s1, 1
    j     compLoop
retZero:
    li    $v0, 0
    jr    $ra
retPos:
    li    $v0, 1
    jr    $ra
retNeg:
    li    $v0, -1
    jr    $ra

.globl main
main:
    li   $v0, 4
    la   $a0, prompt1
    syscall
    li   $v0, 8
    la   $a0, buf1
    li   $a1, 1024
    syscall

    li   $v0, 4
    la   $a0, prompt2
    syscall
    li   $v0, 8
    la   $a0, buf2
    li   $a1, 1024
    syscall

    la   $a0, buf1
    la   $a1, buf2
    jal  compareStrings

    li   $v0, 4
    la   $a0, msgComp
    syscall

    li   $v0, 4
    la   $a0, msgRes
    syscall

    move $t7, $v0
    li   $v0, 1
    move $a0, $t7
    syscall

    li   $v0, 4
    la   $a0, nl
    syscall
    jr   $ra
