.data

	array: .word 4:4
	
.text

	main:
		la $s0, array
		lw $t0, 8($s0)
		
		move $a0, $t0
		li $v0, 1
		syscall