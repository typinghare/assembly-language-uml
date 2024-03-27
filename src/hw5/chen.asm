# Copyright 2024 James Chen
# Assembly Language, Homework 5

# To graders: It was really a tough code marathon. I spent much time implementing it, and eventually, 
# the program passes all the following test cases:
# 1. `Thisloop:	li 	$t0,63		#`  (this is in the instructions)
# 2. `123 + aB / a7 #`  (This case tests if the program groups "a" and "7")
# 3. `:::98a37 #` (This case tests if the program separate "98" and "a37" correctly)
# 4. `9 ^ c #` (This case tests if the program outputs an error message and exists 
#               when an unknown character is encountered)
# 5. `#` (A trivial case)
# 6. `& #` (A trivial case that triggers the error action)
# 7. `lb	$t1 tabToken+8($t0) #` (A random case)

# Note: Upon an invalid/unknown charactered is encountered, the program outputs "Fatal error encountered!"
# and exits immediately.

.data
	# Input line string buffer
	inBuf: .space 80
	
	# The index of the next character to process in inBuf
	inBufCharIndex: .word 0
	
	# Space to copy one token at a time
	prToken: .word 0:3
	
	# Token space
	tokSpace: .word 8
	
	# 20 entries and each token takes up three words (20 * 3 = 60 words)
	# An entry consists of a token (8 bytes, 8 chars) and a token type (4 bytes, int)
	tabToken: .space 240
	
	# The index of the next available token entry
	tabTokenIndex: .word 0
	
	# Table head string
	tableHead: .asciiz "TOKEN    TYPE\n"
	
	# Whether to stop the state machine
	returnKey: .word 0
	
	# TabState
	tabState:
Q0:     .word  ACT1
        .word  Q1   # T1
        .word  Q1   # T2
        .word  Q1   # T3
        .word  Q1   # T4
        .word  Q1   # T5
        .word  Q1   # T6
        .word  Q11  # T7

Q1:     .word  ACT2
        .word  Q2   # T1
        .word  Q5   # T2
        .word  Q3   # T3
        .word  Q3   # T4
        .word  Q4   # T5
        .word  Q0   # T6
        .word  Q11  # T7

Q2:     .word  ACT1
        .word  Q6   # T1
        .word  Q7   # T2
        .word  Q7   # T3
        .word  Q7   # T4
        .word  Q7   # T5
        .word  Q7   # T6
        .word  Q11  # T7

Q3:     .word  ACT4
        .word  Q0   # T1
        .word  Q0   # T2
        .word  Q0   # T3
        .word  Q0   # T4
        .word  Q0   # T5
        .word  Q0   # T6
        .word  Q11  # T7

Q4:     .word  ACT4
        .word  Q10  # T1
        .word  Q10  # T2
        .word  Q10  # T3
        .word  Q10  # T4
        .word  Q10  # T5
        .word  Q10  # T6
        .word  Q11  # T7

Q5:     .word  ACT1
        .word  Q8   # T1
        .word  Q8   # T2
        .word  Q9   # T3
        .word  Q9   # T4
        .word  Q9   # T5
        .word  Q9   # T6
        .word  Q11  # T7

Q6:     .word  ACT3
        .word  Q2   # T1
        .word  Q2   # T2
        .word  Q2   # T3
        .word  Q2   # T4
        .word  Q2   # T5
        .word  Q2   # T6
        .word  Q11  # T7

Q7:     .word  ACT4
        .word  Q1   # T1
        .word  Q1   # T2
        .word  Q1   # T3
        .word  Q1   # T4
        .word  Q1   # T5
        .word  Q1   # T6
        .word  Q11  # T7

Q8:     .word  ACT3
        .word  Q5   # T1
        .word  Q5   # T2
        .word  Q5   # T3
        .word  Q5   # T4
        .word  Q5   # T5
        .word  Q5   # T6
        .word  Q11  # T7

Q9:     .word  ACT4
        .word  Q1  # T1
        .word  Q1  # T2
        .word  Q1  # T3
        .word  Q1  # T4
        .word  Q1  # T5
        .word  Q1  # T6
        .word  Q11 # T7

Q10:    .word  RETURN
        .word  Q10  # T1
        .word  Q10  # T2
        .word  Q10  # T3
        .word  Q10  # T4
        .word  Q10  # T5
        .word  Q10  # T6
        .word  Q11  # T7

Q11:    .word  ERROR 
	 	.word  Q4  # T1
	 	.word  Q4  # T2
	 	.word  Q4  # T3
	 	.word  Q4  # T4
	 	.word  Q4  # T5
	 	.word  Q4  # T6
	 	.word  Q4  # T7
	 
	 # tabChar tabel
	tabChar: 
		.word 0x09, 6 	# tab
		.word 0x0a, 6	# LF
		.word ' ', 6
 		.word '#', 5
 		.word '$', 4
		.word '(', 4 
		.word ')', 4 
		.word '*', 3 
		.word '+', 3 
		.word ',', 4 
		.word '-', 3 
		.word '.', 4 
		.word '/', 3 
		.word '0', 1
		.word '1', 1 
		.word '2', 1 
		.word '3', 1
		.word '4', 1 
		.word '5', 1 
		.word '6', 1
		.word '7', 1 
		.word '8', 1 
		.word '9', 1 
		.word ':', 4 
		.word 'A', 2
		.word 'B', 2 
		.word 'C', 2 
		.word 'D', 2 
		.word 'E', 2 
		.word 'F', 2 
		.word 'G', 2 
		.word 'H', 2 
		.word 'I', 2 
		.word 'J', 2 
		.word 'K', 2
		.word 'L', 2 
		.word 'M', 2 
		.word 'N', 2 
		.word 'O', 2 
		.word 'P', 2 
		.word 'Q', 2 
		.word 'R', 2 
		.word 'S', 2 
		.word 'T', 2 
		.word 'U', 2
		.word 'V', 2 
		.word 'W', 2 
		.word 'X', 2 
		.word 'Y', 2
		.word 'Z', 2
		.word 'a', 2 
		.word 'b', 2 
		.word 'c', 2 
		.word 'd', 2 
		.word 'e', 2 
		.word 'f', 2
		.word 'g', 2 
		.word 'h', 2 
		.word 'i', 2 
		.word 'j', 2 
		.word 'k', 2
		.word 'l', 2 
		.word 'm', 2 
		.word 'n', 2 
		.word 'o', 2 
		.word 'p', 2 
		.word 'q', 2 
		.word 'r', 2 
		.word 's', 2 
		.word 't', 2 
		.word 'u', 2
		.word 'v', 2 
		.word 'w', 2 
		.word 'x', 2 
		.word 'y', 2
		.word 'z', 2
		.word 0x5c, -1

	# Input string prompt
	inputStringPrompt: .asciiz "Please input a string: "
	 
	# Error message
	errorMessage: .asciiz "Fatal error encountered!"

.text
	.globl  main
	
	# @brief Prompts the user to input a string (max length of 20); breaks the string into tokens
	# and print out the tokens and corresponding types.
	main:
		jal getLine		# Scan a line
	
		# Scan the string
		li	$s0, 1		# Initial T = 1
		la	$s1, Q0		# Initial state CUR = Q0
		
		nextState:
			lw $t0, returnKey	# Stop when returnKey == 1
			bne $t0, $zero, nextStateEnd
			
			lw	$s2, 0($s1)		# Load this state’s ACT
			jalr $v1, $s2		# Call ACT, save return addr in $v1
			sll	$s0, $s0, 2		# Multiply T by 4 for word boundary
			add	$s1, $s1, $s0	# Add T to current state index
			sra	$s0, $s0, 2		# Divide by 4 to restore original T
			lw	$s1, 0($s1)		# Transition to next state
			b	nextState
		nextStateEnd:
	
		lw $a3, tabTokenIndex	# Calculate the index of byte of the last token
		subi $a3, $a3, 1
		mul $a3, $a3, 12
		jal printToken			# Print the token table
	
		li $v0, 10				# Exit the program
		syscall

	# @brief Read next char (curChar) from inBuf. The $s0 will be set as the type of the 
	# next character.
	ACT1:
		li $a0, 0				# Get the next character, but not move the pointer ahead
		jal nextChar
		move $a0, $v0
		
		jal charType			# Get the type of the character
		move $s0, $v0
		
		jr $v1
	
	# @brief TOKEN = curChar, tokSpace = 7
	ACT2:
		# tokSpace = 7
		li $t0, 7
		sw $t0, tokSpace
		
		li $a0, 1				# Get the next character and move the pointer ahead
		jal nextChar
		
		sb $v0, prToken			# Append the character to prToken
		la $t0, prToken			# Save the type to prToken
		sw $s0, 8($t0)
		
		jr $v1
		
	# @brief TOKEN += curChar; TokSpace = TokSpace - 1 
	ACT3:
		li $a0, 1				# Get the current character, but not move the pointer ahead
		jal nextChar
		
		lw $t0, tokSpace
		li $t1, 8
		sub $t0, $t1, $t0		# Find the index to insert
		# For example, TokSpace = 7, $t0 = 1; TokSpace = 6, $t0 = 1
		
		sb $v0, prToken($t0)	# TOKEN += curChar
		
		lw $t0, tokSpace		# TokSpace -= 1
		subi $t0, $t0, 1
		sw $t0, tokSpace
		
		jr $v1
	
	# @brief Save TOKEN into TabToken; Clear Token; TokSpace = 8
	ACT4:
		# tokSpace = 8
		li $t0, 8
		sw $t0, tokSpace
		
		lw $t0, tabTokenIndex	# Append the token prToken to tabToken
		mul $t0, $t0, 12
		la $t1, prToken
		la $t2, tabToken
		add $t2, $t2, $t0
		lw $t3, ($t1)
		sw $t3, ($t2)
		lw $t3, 4($t1)
		sw $t3, 4($t2)
		lw $t3, 8($t1)
		sw $t3, 8($t2)
		
		lw $t0, tabTokenIndex	# Increment tabTokenIndex by 1
		addi $t0, $t0, 1
		sw $t0, tabTokenIndex
		
		li $t0, 0				# Clear the temporary token (prToken)
		la $t1, prToken
		sw $t0, 0($t1)
		sw $t0, 4($t1)
		sw $t0, 8($t1)
	
		jr $v1
	
	# @brief Return
	RETURN:
		lw $t0, tabTokenIndex	# Save the "#" token into tabToken
		mul $t0, $t0, 12
		la $t1, tabToken
		add $t1, $t1, $t0
		li $t2, 0x23
		li $t3, 5
		sw $t2, 0($t1)
		sw $t3, 8($t1)
		
		lw $t0, tabTokenIndex	# Increment tabTokenIndex
		addi $t0, $t0, 1
		sw $t0, tabTokenIndex
	
		li $t0, 1				# Update the returnKey
		sw $t0, returnKey
		
		jr $v1
		
	ERROR:
		la $a0, errorMessage	# Print the error message
		li $v0, 4
		syscall
		
		li $v0, 10
		syscall					# Exit the program
		
		jr $v1
	
	# @brief Gets the next character from the inBuf.
	# @param $a0 Whether to increment inBufCharIndex by 1. 
	# @return $v0 The current character.
	nextChar:
		lw $t0, inBufCharIndex				# Load the next character
		lb $v0, inBuf($t0)
		
		beqz $a0, nextCharAfterIncrement	# If $a0 == 0, skip the increment
		addi $t0, $t0, 1					# Increment inBufCharIndex by 1
		sb $t0, inBufCharIndex
		nextCharAfterIncrement:
		
		jr $ra
		
	# @brief Reads a line and store it to the inBuf.
	getLine:
		la $a0, inputStringPrompt
		li $v0, 4
		syscall								# Print the prompt message
		
		la $a0, inBuf						# Address of input buffer
		li $a1, 80							# Maximum number of characters to read
		li $v0, 8
		syscall								# Read a new line
		
		jr $ra
		
	# @brief Gets the type of a specified character. If the character is not in the tabChar,
	# this function will print an error message and exit the program.
	# @param $a0 The character to get the type of.
	# @return $v0 The type of the character.
	charType:
		la $t0, tabChar
		
		getTypeLoop:
			lw $t1, 0($t0)					# The character
			lw $t2, 4($t0)					# The character type 
			
			beq $a0, $t1, getTypeFoundChar	# If $a0 == $t1, return $t2
			addi $t0, $t0, 8				# $t0 += 8
			bne $t2, -1, getTypeLoop		# -1 is the last type
		getTypeLoopEnd:
		li $v0, 7							# Let $v0 to be 7
		jr $ra
		
		getTypeFoundChar:
		move $v0, $t2						# Move $t2 to $v0 as return value
		jr $ra

	# @brief Prints token table header; copies each entry of tabToken into prToken and print TOKEN.
	# @param $a3 The byte index to last entry in the tabToken.
	# @note This function is copied from the instruction
	printToken:
		la $a0, tableHead
		li $v0, 4
		syscall				# Print the table header
		
		# copy 2-word token from tabToken into prToken
		# run through prToken, and replace 0 (Null) by ' ' (0x20)
		# so that printing does not terminate prematurely
		li $t0, 0
		loopTok:
			bge $t0, $a3, donePrTok		# Break the loop (loopTok) if $t0 >= $a3
			
			# Copy tabTok[] into prTok
			lw $t1, tabToken($t0)
			sw $t1, prToken
			lw $t1, tabToken + 4($t0)
			sw $t1, prToken + 4
			
			li	$t7, 0x20	# blank in $t7 (0x20 is the space character)
			li	$t9, -1		# for each char in prTok
			
			loopChar:
				addi $t9, $t9, 1
				bge	$t9, 8, tokType			# break the loop (loopChar) if $t9 >= 8
				lb	$t8, prToken($t9)
				bne	$t8, $zero, loopChar	# Continue if char != 0
				sb	$t7, prToken($t9)		# Replace the byte by ' ' (0x20) 
				b	loopChar
			
			# to print type, use four bytes: ' ', char(type), '\n', and Null
			# in order to print the ASCII type and newline
			tokType:
				li	$t6, '\n'			# newline in $t6
				sb	$t7, prToken + 8
		
				#sb	$t7, prToken+9
				lb	$t1, tabToken + 8($t0)
				addi $t1, $t1, 0x30		# ASCII(token type)
				sb	$t1, prToken+9
		
				sb	$t6, prToken + 10	# terminate with '\n'
				sb	$0, prToken + 11
				la	$a0, prToken		# print token and its type
				li	$v0, 4
				syscall
	
				addi $t0, $t0, 12
				sw	$0, prToken				# clear prToken
				sw	$0, prToken + 4
				b	loopTok

		donePrTok:
		jr $ra
