# Data section
.data
	x: .word 0, 0, 0

# Code section
.text
	.globl main
	
	main:
		la $a0, x
		li $t5, 0
		li $t6, 3
		
		read_loop_start:
			move $a1, $t5
			jal read_int
			addi $t5, $t5, 1
			bgt $t6, $t5, read_loop_start

		# Find the summation ($s0 = x[0] + x[1] + x[2])
		li $s0, 0
		li $a1, 0
		sum_loop_start:
			jal get_addr
			move $t0, $v0
			lw $t1, 0($t0)
			add $s0, $s0, $t1
			add $a1, $a1, 1
			bgt $t6 $a1, sum_loop_start
		
		# Print $s0
		move $a0, $s0
		jal print_int
		
		# Exit the program
    	li $v0, 10
    	syscall
    	
    # @function Returns the address of a certanin element in an array given its base address and an offset.
	# @arg $a0 - The address of an array.
	# @arg @a1 - The offset number.
	get_addr:						# int *get_addr(void *array, int offset) {
		sll $v0, $a1, 2				#     long $v0 = offset << 2;
		add $v0, $v0, $a0			#     $v0 += array;
		jr $ra						#	  return $v0;
									# }
	
	# @function Reads an integer.
	# @arg $a0 - The address of an array.
	# @arg $a1 - The offset number.
	read_int:						# int* read(int* array, int offset) {
		li $v0, 5					#	  int $v0;  
		syscall						#	  scanf("%d", &$v0);
		move $t0, $v0				#     int* $t0 = &$v0;
									
		# Save the return addr		#
		move $t2, $ra				#
		jal get_addr				#     int* $v0 = get_addr(array, offset)
							
		# Restore the return addr	#
		move $ra, $t2				#
		sw $t0, 0($v0) 				#     *$v0 = *$t0;
		jr $ra						#     return $v0;
									# }
	
	# @function print an integer.
	# @arg $a0 - The integer to print.
	print_int:
		li $v0, 1
		syscall
		jr $ra