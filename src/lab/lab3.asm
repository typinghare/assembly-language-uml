.data 
	# The array to sort
	Array: .word 64, 25, 12, 22, 11, 75, 1
	
	# The length of the array
	N: .word 7
	
	# The separator to split elements when printing arrays
	Separator: .asciiz " "
	
	# Some messages
	MessagePrintOriginalArray: .asciiz "The original array: \n"
	
	# Some messages
	MessagePrintSortedArray: .asciiz "\n\nThe sorted array: \n"

.text
	.globl main

	# @brief Sorts the array and prints it out.
	main:
		# Print the original array
		li $v0, 4
		la $a0, MessagePrintOriginalArray
		syscall
		la $a0, Array
		la $a1, N
		lw $a1, 0($a1)
		jal print_array
	
		# Apply selection sort
		la $a0, Array
		la $a1, N
		lw $a1, 0($a1)
		jal selection_sort
		
		# Print the sorted array
		li $v0, 4
		la $a0, MessagePrintSortedArray
		syscall
		la $a0, Array
		la $a1, N
		lw $a1, 0($a1)
		jal print_array
		
		# Exit the program
		j exit
	
	# @brief Sorts an array in ascending order using selection sort.
	# @param $a0 The array to sort.
	# @param $a1 The size of the array to sort.
	selection_sort:
		move $t0, $a1										# $t0 = $a1
		srl $t0, $t0, 1										# $t0 = $t0 / 2 = N / 2
		li $t1, 0											# $t1 := i
		
		selection_sort_loop:
			bgt $t1, $t0, selection_sort_loop_end			# if (i > N / 2) goto selection_sort_loop_end
			move $t2, $t1									# $t2 := min = i
			move $t3, $t1									# $t3 := max = i
			addi $t4, $t3, 1								# $t4 := j = i + 1
			
			selection_sort_inner_loop:
				sub $t5, $a1, $t1							# $t5 = N - i
				bge $t4, $t5, selection_sort_inner_loop_end	# if (j >= N - i) goto selection_sort_inner_loop_end
				
				# $t5 = A[j]
				sll $t5, $t4, 2								# $t5 = $t4 * 4 = j * 4
				add $t5, $t5, $a0 							# $t5 = $t5 + $a0 = &A[j]
				lw $t5, 0($t5)								# $t5 = A[j]
				
				# $t6 = A[max] = $a0[$t3]
				sll $t6, $t3, 2								# $t6 = $t3 * 4 = max * 4
				add $t6, $t6, $a0							# $t6 = $t6 + $a0 = &A[max]
				lw $t6, 0($t6)								# $t6 = A[max]
				
				ble $t5, $t6, selection_sort_inner_else		# if (A[j] <= A[max]) goto selection_sort_inner_else
				move $t3, $t4								# max = j
				j selection_sort_update_j					# goto selection_sort_update_j
				
				selection_sort_inner_else:
					beq $t5, $t6, selection_sort_update_j	# if (A[j] == A[max]) goto selection_sort_update_j
					move $t2, $t4							# min = j
				
				selection_sort_update_j:
					addi $t4, $t4, 1						# j = j + 1
					j selection_sort_inner_loop				# goto selection_sort_inner_loop
			selection_sort_inner_loop_end:
			
			# $t5 = &A[i], $t7 = &A[min]
			sll $t5, $t1, 2								# $t5 = $t1 * 4 = i * 4
			add $t5, $t5, $a0 							# $t5 = $t5 + $a0 = &A[i]
			sll $t7, $t2, 2								# $t7 = $t2 * 4 = min * 4
			add $t7, $t7, $a0							# $t7 = $t7 + $a0 = &A[min]
				
			# Swap A[i] and A[min]
			lw $t6, 0($t5)								# $t6 := tmp = A[i]
			lw $t8, 0($t7)								# $t8 = A[min]
			sw $t8, 0($t5)								# A[i] = A[min]
			sw $t6, 0($t7)								# A[min] = tmp
				
			# $t5 = &A[N - 1 - i], $t7 = &A[max]
			subi $t5, $a1, 1							# $t5 = N - 1
			sub $t5, $t5, $t1							# $t5 = N - 1 - i
			sll $t5, $t5, 2								# $t5 = 4 * $t5
			add $t5, $t5, $a0							# $t5 = &A[N - 1 - i]
			sll $t7, $t3, 2								# $t7 = $t3 * 4 = max * 4
			add $t7, $t7, $a0							# $t7 = $t7 + $a0 = &A[max]
				
			# Swap A[N - 1 - i] and A[max]
			lw $t6, 0($t5)								# tmp = A[N - 1 - i]
			lw $t8, 0($t7)								# $t8 = A[max]
			sw $t8, 0($t5)								# A[N - 1 - i] = A[max]
			sw $t6, 0($t7)								# A[max] = tmp
				
			addi $t1, $t1, 1							# i = i + 1
			j selection_sort_loop						# goto selection_sort_loop
		selection_sort_loop_end:						
		
		jr $ra											# return
		
	# @brief Prints an integer array.
	# @param $a0 The array to sort.
	# @param $a1 The size of the array to sort.
	print_array:
		move $t0, $a0
		li $t1, 0
		
		print_array_loop:
			bge $t1, $a1, print_array_loop_end
			
			li $v0, 1
			lw $a0, 0($t0)
			syscall
			
			li $v0, 4
			la $a0, Separator
			syscall
			
			addi $t0, $t0, 4
			addi $t1, $t1, 1
			
			j print_array_loop
		print_array_loop_end:
			
		jr $ra
	
	# @brief Exits the program.
	exit:
		li $v0, 10
		syscall 
