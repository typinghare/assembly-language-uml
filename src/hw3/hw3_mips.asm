.data 
	# The array to test
	Array: .word 64, 25, 12, 22, 11, 75, 1, 0
	
	# The separator to split elements when printing arrays
	Separator: .asciiz " "
	
	# Newline character
	Newline: .asciiz "\n"
	
	# Some messages
	MessagePrintArray: .asciiz "The array is: "
	
.text
	.globl main
	
	# @brief 
	main:
		# Print the array
		li $v0, 4
		la $a0, MessagePrintArray
		syscall											# printf("The array is: ")
		la $a0, Array
		li $a1, 7
		jal print_array									# print_array(Array, 7)
		li $v0, 4
		la $a0, Newline
		syscall											# printf("\n")
		
		# Search 11 and print the result (should be 4)
		la $a0, Array
		li $a1, 11
		jal search										# $v0 = search(Array, 20)
		move $a0, $v0									
		li $v0, 1
		syscall											# printf("%d", $v0)
		li $v0, 4
		la $a0, Newline
		syscall											# printf("\n")
		
		# Search 20 and print the result (should be -1)
		la $a0, Array
		li $a1, 20
		jal search										# $v0 = search(Array, 20)
		move $a0, $v0									
		li $v0, 1
		syscall											# printf("%d", $v0)
		
		# Exit the program
		j exit
		
		
	# @brief Finds an elment 
	# @param $a0 The array to find. The elements in the array should be all positive. The array
	#			 should end with a 0.
	# @param $a1 The key to find.
	# @return $v0 The index of the key element; -1 if the key does not exist in the array.
	search:												# search($a0, $a1) {
		li $t0, 0										# 	$t0 := i
		li $t1, 0										# 	$t1 := found (boolean)
														#
		search_while:									# 	while (true) {
			beq $t1, 1, search_while_end				#		if (found) goto search_while_end;
														#
			sll $t2, $t0, 2								#		$t2 = i << 2	// offset
			add $t2, $t2, $a0							#		$t2 = $t2 + $a0	// &X[i]
			lw $t2, 0($t2)								#       $t2 = *$t2		// $t2 := X[i]
			beq $t2, 0, search_while_end				#		if (X[i] == 0) goto search_while_end
														#
			bne $t2, $a1, else1							# 	if (X[i] == key) goto else1
				li $t1, 1								#		found = 1
				j if_end_1								#       goto if_end_1
			else1:										#	else1:
				addi $t0, $t0, 1						#		i = i + 1
			if_end_1:									#	if_end_1:
			j search_while								# 
		search_while_end:								#   }
														#
		bne $t1, 1, else2								# if (!found) goto else2
			move $v0, $t0								# 
			jr $ra										# 	return i;
		else2:											# else2:
			li $v0, -1									#
			jr $ra										# 	return -1;
														#
															
	# @brief Prints an integer array.					
	# @param $a0 The array to sort.						
	# @param $a1 The size of the array to sort.			
	print_array:										# print_array($a0, $a1) {
		move $t0, $a0									#
		li $t1, 0										#
														#
		print_array_loop:								#
			bge $t1, $a1, print_array_loop_end			# 	while ($t1 != $a1) {
														# 
			li $v0, 1									#	
			lw $a0, 0($t0)								#	
			syscall										#		print(*$t0);
													    #
			li $v0, 4									#
			la $a0, Separator							#
			syscall										#		print(" ");
														#
			addi $t0, $t0, 4							#   	$t0 = $t0 + 4
			addi $t1, $t1, 1							#		$t1 = $t1 + 1
														#
			j print_array_loop							# 	}
		print_array_loop_end:							#
														#
		jr $ra											# 	return;
														# }
	# @brief Exits the program.							#
	exit:												# exit() {
		li $v0, 10										#	exit(0);
		syscall 										# }
