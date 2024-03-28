# Copyright 2024 James Chen
# Assembly Language, Homework 6

# To graders: I enhanced my HW5 code by adhering to MIPS best practices and implementing optimizations in some 
# loops. I examined the program using the specified test case outlined in the instructions and the output precisely
# matches the expected output delineated in the instructions.
# However, I didn't completely follow the pseudo-C code in the instructions (the updated version), as I found a
# mistake in it: the "i" is set to be 2 in the case where the first token is a label in "labelDef". However, that
# will not skip the instruction. I changed it into "i = 3", at line 454 in this file, and it worked finally.

.data

# Input line string buffer (length: 80 bytes)
inBuf: 			.word 0:20		
	
# The index of the next character to process in inBuf
inBufCharIndex: .word 0
	
# Space to copy one token at a time
prToken: 		.word 0:3
	
# Token space
tokSpace: 		.word 8
	
# 20 entries and each token takes up three words (20 * 3 = 60 words)
# An entry consists of a token (8 bytes, 8 chars) and a token type (4 bytes, int)
tabToken: 		.word 0:60
	
# The index of the next available token entry
tabTokenIndex: 	.word 0

# 8 entries and each symbol takes up four words (8 * 4 = 32 words)
# An entry consists of a label (8 chars), a value (1 int), and a status (1 int) 
tabSymbol:		.word 0:32

# The index of the next available symbol entry
tabSymbolIndex: .word 0

# The address of the first instruction
loc:			.word 0x0400
	
# Table head string
tableHead: 		.asciiz "TOKEN    TYPE\n"
	
# Whether to stop the state machine
returnKey: 		.word 0

# For the function "hex2char"
saveReg:		.word	0:3

# table of states
tabState:
Q0:     		.word  ACT1
        		.word  Q1   # T1
        		.word  Q1   # T2
        		.word  Q1   # T3
        		.word  Q1   # T4
       		 	.word  Q1   # T5
        		.word  Q1   # T6
        		.word  Q11  # T7

Q1:     		.word  ACT2
        		.word  Q2   # T1
        		.word  Q5   # T2
        		.word  Q3   # T3
        		.word  Q3   # T4
        		.word  Q4   # T5
        		.word  Q0   # T6
        		.word  Q11  # T7

Q2:     		.word  ACT1
        		.word  Q6   # T1
        		.word  Q7   # T2
        		.word  Q7   # T3
        		.word  Q7   # T4
        		.word  Q7   # T5
        		.word  Q7   # T6
        		.word  Q11  # T7

Q3:     		.word  ACT4
        		.word  Q0   # T1
        		.word  Q0   # T2
        		.word  Q0   # T3
        		.word  Q0   # T4
        		.word  Q0   # T5
        		.word  Q0   # T6
        		.word  Q11  # T7

Q4:    		 	.word  ACT4
        		.word  Q10  # T1
        		.word  Q10  # T2
        		.word  Q10  # T3
        		.word  Q10  # T4
        		.word  Q10  # T5
        		.word  Q10  # T6
        		.word  Q11  # T7

Q5:     		.word  ACT1
        		.word  Q8   # T1
        		.word  Q8   # T2
        		.word  Q9   # T3
        		.word  Q9   # T4
        		.word  Q9   # T5
        		.word  Q9   # T6
        		.word  Q11  # T7

Q6:     		.word  ACT3
        		.word  Q2   # T1
        		.word  Q2   # T2
        		.word  Q2   # T3
        		.word  Q2   # T4
        		.word  Q2   # T5
        		.word  Q2   # T6
        		.word  Q11  # T7

Q7:     		.word  ACT4
        		.word  Q1   # T1
        		.word  Q1   # T2
        		.word  Q1   # T3
        		.word  Q1   # T4
        		.word  Q1   # T5
        		.word  Q1   # T6
        		.word  Q11  # T7

Q8:     		.word  ACT3
        		.word  Q5   # T1
        		.word  Q5   # T2
        		.word  Q5   # T3
        		.word  Q5   # T4
        		.word  Q5   # T5
        		.word  Q5   # T6
       			.word  Q11  # T7

Q9:     		.word  ACT4
        		.word  Q1  # T1
        		.word  Q1  # T2
        		.word  Q1  # T3
        		.word  Q1  # T4
        		.word  Q1  # T5
        		.word  Q1  # T6
        		.word  Q11 # T7

Q10:    		.word  RETURN
        		.word  Q10  # T1
        		.word  Q10  # T2
        		.word  Q10  # T3
        		.word  Q10  # T4
        		.word  Q10  # T5
        		.word  Q10  # T6
        		.word  Q11  # T7

Q11:    		.word  ERROR 
	 			.word  Q4  # T1
	 			.word  Q4  # T2
	 			.word  Q4  # T3
	 			.word  Q4  # T4
	 			.word  Q4  # T5
	 			.word  Q4  # T6
	 			.word  Q4  # T7
	
tabChar: 		.word 0x09, 6 	# tab
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
				
# Strings
newlineCharacter:	.asciiz "\n"
tabCharacter:		.asciiz "\t"
inputStringPrompt: 	.asciiz "Please input a string: "
errorMessage: 		.asciiz "Fatal error encountered!"
tabSymString:		.asciiz "tabSym:"

.text
.globl  main

# @brief Prompts the user to input a string (max length of 20); breaks the string into tokens
# and print out the tokens and corresponding types.
main:			
mainLp:			jal getLine				# Scan a line (read_line)
				li	$s0, 1				# Initial s0 := T = 1
				la	$s1, Q0				# Initial state s1 := CUR = Q0
nextState:		lw $t0, returnKey		# Stop when returnKey == 1
				bne $t0, $zero, nextStateEnd
				lw	$s2, 0($s1)			# Load this state’s ACT
				jalr $v1, $s2			# Call ACT, save return addr in $v1
				sll	$s0, $s0, 2			# Multiply T by 4 for word boundary
				add	$s1, $s1, $s0		# Add T to current state index
				sra	$s0, $s0, 2			# Divide by 4 to restore original T
				lw	$s1, 0($s1)			# Transition to next state
				b	nextState
nextStateEnd:
				jal chkLabelDef			# Call chkLabelDef
				move $a0, $v0			# The "i"
				jal chkIns				# Call chkIns
				jal printTabSymbol		# Print the symbol table
				jal clearInBuf			# Clear inBuf
				jal clearTabToken		# Clear the token table
				lw $t0, loc				# LOC += 4	
				addi $t0, $t0, 4
				sw $t0, loc
				sw $zero, returnKey		# Set the return key to zero
				b mainLp				# Repeat the main loop
mainLpEnd:
				li $v0, 10				# Exit the program
				syscall
			
# @brief Read next char (curChar) from inBuf. The $s0 will be set as the type of the next character.
ACT1:			li $a0, 0				# Get the next character without moving the pointer ahead
				jal nextChar
				move $a0, $v0
				jal charType			# Get the type of the character
				move $s0, $v0			# Set T to be the type of the character
				jr $v1					# Return
			
# @brief Appends the current character to the empty token string and sets tokSpace to 7.
ACT2:			li $t0, 7				# Set tokSpace to 7
				sw $t0, tokSpace
				li $a0, 1				# Get the next character and move the pointer ahead
				jal nextChar
				la $t0, prToken			# Get the address of prToken
				sb $v0, 0($t0)			# Append the character to prToken
				sw $s0, 8($t0)			# Save the type to prToken
				jr $v1					# Return
			
# @brief Appends the current character to the token string and decrements tokSpace
ACT3:			li $a0, 1				# Get the current character without moving the pointer ahead
				jal nextChar
				lw $t0, tokSpace		# Find the index to insert into
				li $t1, 8	
				sub $t0, $t1, $t0		# For example, TokSpace = 7, $t0 = 1; TokSpace = 6, $t0 = 1
				sb $v0, prToken($t0)	# Appends curChar to prToken string
				lw $t0, tokSpace		# Decrement TokSpace by 1
				subi $t0, $t0, 1
				sw $t0, tokSpace
				jr $v1					# Return
			
# @brief Saves prToken into TabToken, clears prToken and sets tokSpace to 8.
ACT4:			li $t0, 8				# Set tokSpace to 8
				sw $t0, tokSpace
				lw $t0, tabTokenIndex	# Get the index of the current tab token
				mul $t0, $t0, 12		# Multiply by 12 to get the relative address
				la $t1, prToken			# Load the address of prToken
				la $t2, tabToken		# load the address of tabToken
				add $t2, $t2, $t0		# Find the address of the destination tab token
				lw $t3, ($t1)			# Copy prToken to the destination tab token
				sw $t3, ($t2)
				lw $t3, 4($t1)
				sw $t3, 4($t2)
				lw $t3, 8($t1)
				sw $t3, 8($t2)
				lw $t0, tabTokenIndex	# Increment tabTokenIndex by 1
				addi $t0, $t0, 1
				sw $t0, tabTokenIndex
				li $t0, 0				# Clear the temporary token (prToken)
				la $t1, prToken			# Load the address of prToken
				sw $t0, 0($t1)
				sw $t0, 4($t1)
				sw $t0, 8($t1)
				jr $v1					# Return
			
# @brief Saves the "#" token into tabToken array, increments tabTokenIndex, and updates the returnKey to 1
RETURN:
				lw $t0, tabTokenIndex	# Save the "#" token into tabToken
				mul $t0, $t0, 12		# Multiply by 12 to get the relative address
				la $t1, tabToken		# Load the address of tabToken
				add $t1, $t1, $t0		# Find the address of the destination tab token
				li $t2, 0x23			# The ASCII index for "#" is "0x23"
				sw $t2, 0($t1)			# Save "#" into the token string
				li $t2, 5				# The token type of "#" is 5
				sw $t2, 8($t1)			# Save the token type
				lw $t0, tabTokenIndex	# Increment tabTokenIndex by 1
				addi $t0, $t0, 1
				sw $t0, tabTokenIndex
				li $t0, 1				# Update the returnKey by setting it to 1
				sw $t0, returnKey
				jr $v1					# Return
			
# @brief Prints the error message and exits the program.
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
nextChar:		lw $t0, inBufCharIndex	# Load the next character
				lb $v0, inBuf($t0)
				beqz $a0, nextCharRt
				addi $t0, $t0, 1		# Increment inBufCharIndex by 1
				sb $t0, inBufCharIndex
nextCharRt:
				jr $ra					# Return

# @brief Reads a line and store it to the inBuf.
getLine:		la $a0, inputStringPrompt
				li $v0, 4
				syscall					# Print the prompt message
				la $a0, inBuf			# Address of input buffer
				li $a1, 80				# Maximum number of characters to read
				li $v0, 8
				syscall					# Read a new line
				jr $ra					# Return
		
# @brief Gets the type of a specified character. If the character is not in the tabChar,
# this function will print an error message and exit the program.
# @param $a0 The character to get the type of.
# @return $v0 The type of the character.
charType:		la $t0, tabChar
charTypeLp:		lw $t1, 0($t0)					# The character
				lw $t2, 4($t0)					# The character type 
				beq $a0, $t1, charTypeFound		# If $a0 == $t1, return $t2
				addi $t0, $t0, 8				# $t0 += 8
				bne $t2, -1, charTypeLp			# -1 is the last type
charTypeLpEnd:
				li $t2, 7						# Let $t2 (the return value) be 7
charTypeFound:
				move $v0, $t2					# Move $t2 to $v0 as return value
				jr $ra							# Return

# @brief Clears inBuf.
clearInBuf: 	la $t0, inBuf					# Load the address of inBuf
				li $t1, 80						# The length (bytes) of inBuf
				li $t2, 0						# Index (i)
clearInBufLp: 	beq $t2, $t1, clearInBufLpEnd	# Break the loop when i == 80
				sb $zero, ($t0)					# Clear the byte
				addi $t0, $t0, 1        		# Increment the pointer to move to the next byte
				addi $t2, $t2, 1				# Increment i by 1
				b clearInBufLp					# Repeat the loop
clearInBufLpEnd:
				sw $zero, inBufCharIndex		# Reset inBufCharIndex to 0
				jr $ra							# Return
		
# @brief Clears the token table (tabToken).
clearTabToken:	la $t0, tabToken				# Load the address of tabToken
				lw $t1, tabTokenIndex			# The index to the next available token
				li $t2, 0						# Index (i)
clearTabTokenLp:beq $t2, $t1, clearTabTokenLpEnd
				sw $zero 0($t0)					# Clear the three words
				sw $zero 4($t0)
				sw $zero 8($t0)
				addi $t0, $t0, 12				# Move the pointer to the next tabToken
				addi $t2, $t2, 1				# increment i by 1
				b clearTabTokenLp				# Repeat the loop
clearTabTokenLpEnd:
				sw $zero, tabTokenIndex			# Set tabTokenIndex to 0
				jr $ra							# Return

# @brief Appends a symbol.
# @param $a0 The address of the token.
# @param $a1 The status.
appendSymbol:	lw $t0, tabSymbolIndex			# Load next available symbol index
				sll $t0, $t0, 4					# Multiply index by 16 to get address offset
				la $t1 tabSymbol				# Load the address of the symbol table
				addu $t0, $t0, $t1				# Calculate address of destination symbol
				lw $t1, 0($a0)					# Copy token string into destination symbol
				sw $t1, 0($t0)
				lw $t1, 4($a0)
				sw $t1, 4($t0)
				lw $t1, loc						# Save loc to destination symbol
				sw $t1, 8($t0)
				sw $a1, 12($t0)					# Save status to destination symbol
				lw $t0, tabSymbolIndex			# Load next available symbol index
				addi $t0, $t0, 1				# Increment the tabSymbolIndex by 1
				sw $t0, tabSymbolIndex
				jr $ra							# Return

# @brief Checks the label definition.
# @return $v0: The index of the first token to process in chkInstruction.
chkLabelDef: 	la $t0, tabToken				# Load the address of tabToken
				lw $t0, 12($t0)					# tabToken[1][0]
				bne $t0, 0x3A, chkLabelDefIns	# If tabToken[1][0] != ‘:’ then goto chkLabelDefIns
				la $a0, tabToken				# curToken = &tabToken[0]
				li $a1, 1						# The status is 1
				move $s7, $ra					# Save the return address
				jal appendSymbol				# VAR(curToken, 1)
				move $ra, $s7					# Restore the return address
				li $v0, 3						# i = 3 (Skip ':' and instruction)
				b chkLabelDefReturn				
chkLabelDefIns: 
				li $v0, 1						# i = 1
chkLabelDefReturn:
				jr $ra							# Return
				

# @brief Checks the instruction.
# @param $a0 The index of the first token to process.
chkIns: 		li $s0, 1						# $s0 := paramStart = true
				move $s1, $a0					# $s1 := i
chkForVar:		la $s2, tabToken				# Load the address of token table
				mul $t0, $s1, 12				# Calculate the offset
				add $s2, $s2, $t0				# Load the address of the token to process
				lb $t0, ($s2)					# Load tabToken[i][0]
				beq $t0, 0x23, chkInsRtn 		# If tabToken[i][0] == '#' (end character), return
				beq $s0, $zero, chkForComma		# If not paramStart goto chkForComma
				lw $t0, 8($s2)					# Load tabToken[i][1]
				bne $t0, 2, chkForComma			# If tabToken[i][1] != 2 goto chkForComma
				move $a0, $s2					# Move &taboToken[0] to $a0
				li $a1, 0						# The status is 0
				move $s7, $ra					# Store the return address
				jal appendSymbol				# Call VAR(&taboToken[0], 0)
				move $ra, $s7					# Restore the return address
				b chkInsNext					# Process the next token
chkForComma:	lb $t0, ($s2)					# Load tabToken[i][0]
				li $s0, 0						# Set paramStart to false
				bne $t0, 0x2C, chkInsNext		# If tabToken[i][0] == ',' goto chkInsNext
				li, $s0, 1						# paramStart = true if tabToken[i][0] == ','
chkInsNext:		addi $s1, $s1, 1				# i += 1
				b chkForVar						# Repeat; process the next token
chkInsRtn:		jr $ra							# Return

# @brief Prints the symbol table.
printTabSymbol: li $v0, 4
				la $a0, tabSymString			# print "tabSym:"
				syscall
				li $s0, 0						# $t0 := i = 0 (The index of symbol)
				lw $s1, tabSymbolIndex			# Load the next available symbol index
printTabSymbolLp:
				bge $s0, $s1, printTabSymbolLpEnd
				li $v0, 4						# Print the tab character
				la $a0 tabCharacter			
				syscall
				sll $t0, $s0, 4					# Multiply $t0 by 16
				la $t1, tabSymbol				# Load the address of symbol table
				add $s2, $t0, $t1				# Load the address of destination symbol
				lw $a0, ($s2)					# Print the token string
				move $s7, $ra					# Save the return address
				jal printChars
				lw $a0, 4($s2)
				jal printChars
				li $v0, 4						# Print the tab character
				la $a0 tabCharacter			
				syscall
				lw $a0, 8($s2)					# Load the location
				jal printHex					# Print the location
				move $ra, $s7					# Restore the return address					
				li $v0, 4						# Print the tab character
				la $a0 tabCharacter			
				syscall
				lw $a0, 12($s2)					# Print the status
				li $v0, 1
				syscall
				li $v0, 4						# Print the newline character
				la $a0 newlineCharacter			
				syscall
				addi, $s0, $s0, 1				# i += 1
				b printTabSymbolLp				# Repeat
printTabSymbolLpEnd:
				jr $ra							# Return

# @brief Prints a hex number.
# @brief $a0 The hex number to print.
printHex: 		move $t0, $s7					# Call hex2char without affecting $ra and $s7
				move $s7, $ra
				jal hex2char
				move $ra, $s7
				move $s7, $t0
				move $a0, $v0
				# Print four characters
				li $t1, 0						# $t1 = i = 0
				li $t2, 4						# $t2 := MAX_BYTES = 4
printHexLp:		bge $t1, $t2, printHexRtn		# if i >= MAX_BYTES then return
				li $v0, 11
				syscall
				srl $a0, $a0, 8					# Right shift 8 bits to print the next character
				addi $t1, $t1, 1
				b printHexLp					# Repeat
printHexRtn:	jr $ra							# Return

# @brief Prints a word as characters
# @brief $a0 The word to print.
printChars:		move $t0, $a0					# Move the word into $t0
				li $t1, 0						# $t1 = i = 0
				li $t2, 4						# $t2 := MAX_BYTES = 4
printCharsLp:	bge $t1, $t2, printCharsRtn		# if i >= MAX_BYTES then return
				andi $a0, $t0, 0xFF				# Get the rightmost byte
				beq $a0, 0x0, printSpace		# Print a space if the character is \0
				li $v0, 11						# Print the character
				syscall
				b printCharsNext				# Print the next character
printSpace:		li $a0, 0x20					# Print a space
				li $v0, 11
				syscall
printCharsNext:	addi $t1, $t1, 1
				srl $t0, $t0, 8					# Right shift 8 bits to print the next character
				b printCharsLp					# Repeat; print the next character
printCharsRtn:	jr $ra							# Return
				

# @brief Converts a hex value into ASCII string.
# @param $a0 The hex number to convert.
# @param $v0 The ASCII string.
# @note This code is copied from the instructions.
hex2char:		sw $t0, saveReg($0)				# hex digit to proces
				sw $t1, saveReg+4($0)			# 4-bit mask
				sw $t9, saveReg+8($0)
				li $t1, 0x0000000f				# $t1: mask of 4 bits
				li $t9, 3						# $t9: counter limit
nibble2char:	and $t0, $a0, $t1				# $t0 = least significant 4 bits of $a0
				bgt	$t0, 9, hexAlpha			# if ($t0 > 9) goto alpha; convert 4-bit number to hex char
				addi $t0, $t0, 0x30				# convert to hex digit; hex char '0' to '9'
				b collect
hexAlpha:		addi $t0, $t0, -10				# subtract hex # "A"
				addi $t0, $t0, 0x41				# convert to hex char, A .. F
collect:		sll	$v0, $v0, 8					# make a room for a new hex char
				or $v0, $v0, $t0				# collect the new hex char
				srl	$a0, $a0, 4					# right shift $a0 for the next digit
				addi $t9, $t9, -1				# $t9--
				bgez $t9, nibble2char
				lw $t0, saveReg($0)
				lw $t1, saveReg+4($0)
				lw $t9, saveReg+8($0)
				jr $ra
