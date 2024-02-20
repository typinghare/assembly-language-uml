# Copyright 2024 James Chen

# <Example>
# Input: "THISLOOP:	LWU	R2, 3		#"
# Output: "22222222422221415"

.data
	# Input line string buffer
	inBuf: .space 80
	
	# Output line string buffer; character types for the input line
	outBuf: .space 80
	
	# Prompt message
	prompt: .asciiz "Enter a new input line:\n"
	
	# Error message
	messageInvalidCharacter: .asciiz "Invalid character: "
	
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

.text
	.globl main
	
	# @brief This program asks users to input a line of string, then maps the string into
	# character types byte by byte, and prints the character types sequentially.
	main:
		# Read a line to fill the inBuf
		jal getLine
		
		# Build the outBuf based on the input line in the inBuf
		la $s0, inBuf
		la $s1, outBuf
		mainBuildLoop:
			lb $a0, 0($s0)
			jal getType
			sb $v0, 0($s1)
			
			addi $s0, $s0, 1
			addi $s1, $s1, 1
			
			beq $v0, 5, mainBuildLoopEnd
			b mainBuildLoop
		mainBuildLoopEnd:
		
		# Print the outBuf byte by byte
		la $s0, outBuf
		mainPrintLoop:
			lb $a0, 0($s0)
			beq $a0, 6, mainPrintLoopNext	# The blank type of 6can be left out
			li $v0, 1
			syscall							# print the byte in the ascii form
					
			beq $a0, 5, mainPrintLoopEnd	# If the type is 5, stop printing
			
			mainPrintLoopNext:
			addi $s0, $s0, 1				# Prepare to read the next byte
			b mainPrintLoop
		mainPrintLoopEnd:
	
		li $v0, 10
		syscall								# Exit this program
	
	# @brief Reads a line and store it to the inBuf.
	getLine:
		la $a0, prompt
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
	getType:
		la $t0, tabChar
		
		getTypeLoop:
			lw $t1, 0($t0)					# The character
			lw $t2, 4($t0)					# The character type 
			
			beq $a0, $t1, getTypeFoundChar	# If $a0 == $t1, return $t2
			addi $t0, $t0, 8				# $t0 += 8
			bne $t2, -1, getTypeLoop		# -1 is the last type
		getTypeLoopEnd:
		move $t0, $a0
		la $a0, messageInvalidCharacter
		li $v0, 4
		syscall
		move $a0, $t0
		li $v0, 11							# Print the character in ascii form
		syscall
		li $v0, 10
		syscall								# Exit this program
		
		getTypeFoundChar:
		move $v0, $t2						# Move $t2 to $v0 as return value
		jr $ra
