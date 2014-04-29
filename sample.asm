	lw $a0, count($zero)
	addi $a1, $zero, input
	addi $a2, $zero, output
	j sum
.word 0 0 0 0 0 0 0

count:	.word 5
input:	.word 100 200 300 400 500
output:	.word 0

sum:
	add $t0, $zero, $zero
loop:
	beq $a0, $zero, quit
	add $zero, $zero, $zero
	lw $t1, 0($a1)
	add $t0, $t0, $t1
	addi $a1, $a1, 4
	addi $a0, $a0, -1
	j loop
quit:
	sw $t0, 0($a2)
.word 0 0 0 0 0 0
