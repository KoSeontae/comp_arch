.data
newline:  .asciiz "\n"
prompt:   .asciiz "Enter a 32-bit signed integer (in decimal): "
info:     .asciiz "INFO: fourWayAddAndSub returned:\n"
infoSum:  .asciiz "Sum = "
infoDiff: .asciiz "Difference = "

.text
# fourWayAddAndSub:
#   계산: v0 = a0 + a1 + a2 + a3
#         v1 = a0 - a1 - a2 - a3
fourWayAddAndSub:
    # a1 + a2 + a3를 t0에 계산
    add   $t0, $a1, $a2      # t0 = a1 + a2
    add   $t0, $t0, $a3      # t0 = a1 + a2 + a3
    # sum 계산: a0 + (a1+a2+a3)
    add   $v0, $a0, $t0      # v0 = a0 + t0
    # diff 계산: a0 - (a1+a2+a3)
    sub   $v1, $a0, $t0      # v1 = a0 - t0
    jr    $ra

.globl main
main:
    # 첫 번째 정수 입력
    li    $v0, 4
    la    $a0, prompt
    syscall
    li    $v0, 5
    syscall
    move  $t0, $v0

    # 두 번째 정수 입력
    li    $v0, 4
    la    $a0, prompt
    syscall
    li    $v0, 5
    syscall
    move  $t1, $v0

    # 세 번째 정수 입력
    li    $v0, 4
    la    $a0, prompt
    syscall
    li    $v0, 5
    syscall
    move  $t2, $v0

    # 네 번째 정수 입력
    li    $v0, 4
    la    $a0, prompt
    syscall
    li    $v0, 5
    syscall
    move  $t3, $v0

    # 함수 호출: 인자는 $a0 ~ $a3 에 전달
    move  $a0, $t0
    move  $a1, $t1
    move  $a2, $t2
    move  $a3, $t3
    jal   fourWayAddAndSub

    # 결과값을 각각 t4 (sum)와 t5 (diff)에 저장
    move  $t4, $v0   # t4 <- sum
    move  $t5, $v1   # t5 <- difference

    # 결과 메시지 출력
    li    $v0, 4
    la    $a0, info
    syscall

    # sum 출력
    li    $v0, 4
    la    $a0, infoSum
    syscall
    li    $v0, 1
    move  $a0, $t4
    syscall
    li    $v0, 4
    la    $a0, newline
    syscall

    # difference 출력
    li    $v0, 4
    la    $a0, infoDiff
    syscall
    li    $v0, 1
    move  $a0, $t5
    syscall
    li    $v0, 4
    la    $a0, newline
    syscall

    li    $v0, 0
    jr    $ra
