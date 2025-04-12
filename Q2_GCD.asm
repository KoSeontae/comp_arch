.data
nl:       .asciiz "\n"
prompt:   .asciiz "Enter a 32-bit unsigned integer (in decimal): "
msgGCD:   .asciiz "INFO: calculateGCD returned:\n"
msgRes:   .asciiz "INFO:   $v0 = "

.text
# a0와 a1의 최대공약수를 계산
calculateGCD:
    move  $t0, $a0       # t0 <- A
    move  $t1, $a1       # t1 <- B
gcd_loop:
    beq   $t1, $zero, gcd_finish
    div   $t0, $t1       # A / B; remainder in HI
    mfhi  $t2           # t2 <- remainder
    move  $t0, $t1      # A = B
    move  $t1, $t2      # B = remainder
    j     gcd_loop
gcd_finish:
    move  $v0, $t0      # 결과: 최대공약수
    jr    $ra

.globl main
main:
    li    $v0, 4
    la    $a0, prompt
    syscall
    li    $v0, 5
    syscall
    move  $t4, $v0      # 첫번째 입력

    li    $v0, 4
    la    $a0, prompt
    syscall
    li    $v0, 5
    syscall
    move  $t5, $v0      # 두번째 입력

    move  $a0, $t4
    move  $a1, $t5
    jal   calculateGCD

    li    $v0, 4
    la    $a0, msgGCD
    syscall

    li    $v0, 4
    la    $a0, msgRes
    syscall

    move  $t6, $v0      # t6 <- 결과 (최대공약수)
    li    $v0, 1
    move  $a0, $t6
    syscall

    li    $v0, 4
    la    $a0, nl
    syscall

    li    $v0, 0
    jr    $ra
