.data
nl:       .asciiz "\n"
prm:      .asciiz "Enter a 32-bit signed integer (in decimal): "
info:     .asciiz "INFO: fourWayAddAndSub returned:\n"
msgSum:   .asciiz "INFO:   $v0 = "
msgDiff:  .asciiz "INFO:   $v1 = "

.text
# fourWayAddAndSub:
#   입력: $a0, $a1, $a2, $a3 (32비트 정수)
#   반환: $v0 = a0+a1+a2+a3, $v1 = a0 - a1 - a2 - a3
fourWayAddAndSub:
    add   $t0, $a1, $a2       # t0 = a1 + a2
    add   $t0, $t0, $a3       # t0 = a1 + a2 + a3
    add   $v0, $a0, $t0       # v0 = a0 + t0 (합)
    sub   $v1, $a0, $t0       # v1 = a0 - t0 (차)
    jr    $ra

.globl main
main:
    # 첫 번째 정수 입력
    li    $v0, 4
    la    $a0, prm
    syscall
    li    $v0, 5
    syscall
    move  $t0, $v0

    # 두 번째 정수 입력
    li    $v0, 4
    la    $a0, prm
    syscall
    li    $v0, 5
    syscall
    move  $t1, $v0

    # 세 번째 정수 입력
    li    $v0, 4
    la    $a0, prm
    syscall
    li    $v0, 5
    syscall
    move  $t2, $v0

    # 네 번째 정수 입력
    li    $v0, 4
    la    $a0, prm
    syscall
    li    $v0, 5
    syscall
    move  $t3, $v0

    # 함수 호출
    move  $a0, $t0
    move  $a1, $t1
    move  $a2, $t2
    move  $a3, $t3
    jal   fourWayAddAndSub

    # 결과 출력
    li    $v0, 4
    la    $a0, info
    syscall

    li    $v0, 4
    la    $a0, msgSum
    syscall
    move  $t4, $v0    # 임시로 합을 보관 (만약 후에 v0 소실 우려가 있으면 따로 저장)
    li    $v0, 1
    move  $a0, $t4
    syscall
    li    $v0, 4
    la    $a0, nl
    syscall

    li    $v0, 4
    la    $a0, msgDiff
    syscall
    move  $t5, $v1    # 임시로 차이를 보관
    li    $v0, 1
    move  $a0, $t5
    syscall
    li    $v0, 4
    la    $a0, nl
    syscall

    li    $v0, 0
    jr    $ra
