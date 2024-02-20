.data
	array: .word 0x37, 0x55, 0xF
	
.text
	la $s0, array
	la $s1, array + 4
	la $s2, 8($s0)
	li $a0, 4
	lw $t0, 0($s0)
	lw $t3, array($a0)
	lw $t1, 8($s0)
	lb $t2, ($s0)